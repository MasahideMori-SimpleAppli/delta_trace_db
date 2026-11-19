import 'package:file_state_manager/file_state_manager.dart';
import 'package:delta_trace_db/src/query/util_field.dart';
import 'package:delta_trace_db/src/query/util_date_time.dart';
import 'package:delta_trace_db/src/query/util_portable_numeric.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) This class allows you to specify single-key sorting for
/// the return values of a query.
///
/// (ja) クエリの戻り値について、単一キーでのソートを指定するためのクラスです。
class SingleSort extends CloneableFile implements AbstractSort {
  static const String className = "SingleSort";
  static const String version = "6";
  String field;
  bool reversed;
  EnumValueType vType;
  int? naiveUtcOffsetMinutes;

  /// (en) This class allows you to specify single-key sorting for
  /// the return values of a query.
  /// When sorting with this class, null values are moved to the back in
  /// ascending sorting and to the front in descending sorting.
  /// Also, boolean values are calculated as 1 for true and 0 for false.
  ///
  /// (ja) クエリの戻り値について、単一キーでのソートを指定するためのクラスです。
  /// このクラスのソートでは、null値は昇順ソートでは後ろに、降順ソートでは前に移動します。
  /// また、bool値はtrueなら1、falseなら0として計算されます。
  /// * [field] : The name of the variable within the class to use for sorting.
  /// * [reversed] : Specifies whether to reverse the sort result.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// A value that cannot be converted is treated as null
  /// (e.g. a non-numeric string, or a bool, NaN or infinity with int_).
  /// With datetime_, when a timezone-aware (UTC) value is compared with
  /// a naive (local) value, the naive value is treated as null.
  /// With auto_, values are compared as they are, and the query fails
  /// if they cannot be compared.
  /// The results are identical to the Python version.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before sorting,
  /// so aware and naive values are sorted together. Must be greater than
  /// -1440 and less than 1440.
  SingleSort({
    required this.field,
    this.reversed = false,
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory SingleSort.fromDict(Map<String, dynamic> src) {
    return SingleSort(
      field: src["field"],
      reversed: src["reversed"] ?? false,
      vType: src.containsKey("vType")
          ? EnumValueType.values.byName(src["vType"])
          : EnumValueType.auto_,
      naiveUtcOffsetMinutes: src["naiveUtcOffsetMinutes"],
    );
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "field": field,
      "reversed": reversed,
      "vType": vType.name,
      "naiveUtcOffsetMinutes": naiveUtcOffsetMinutes,
    };
  }

  @override
  SingleSort clone() {
    return SingleSort.fromDict(toDict());
  }

  /// (en) A method that converts data to a specified type.
  ///
  /// (ja) 指定された型にデータを変換するメソッドです。
  ///
  /// * [value] : The conversion target.
  ///
  /// Throws on [Exception] if the [value] is cannot conversion.
  /// Converts a value with vType. Returns null if it cannot be converted.
  dynamic _convertValue(dynamic value) {
    if (value == null) return null;
    switch (vType) {
      case EnumValueType.datetime_:
        NaiveOrUtc? d;
        if (value is DateTime) d = UtilDateTime.fromDateTime(value);
        if (value is String) d = UtilDateTime.tryParse(value);
        if (d != null && naiveUtcOffsetMinutes != null) {
          return (
            value: UtilDateTime.toUtc(d, naiveUtcOffsetMinutes!),
            isNaive: false,
          );
        }
        return d;
      case EnumValueType.int_:
        if (value is int) return value;
        if (value is double) return value.isFinite ? value.toInt() : null;
        if (value is String) return int.tryParse(value);
        return null;
      case EnumValueType.floatStrict_:
      case EnumValueType.floatEpsilon12_:
        double? d;
        if (value is num) d = value.toDouble();
        if (value is String) d = double.tryParse(value);
        return d != null && !d.isNaN ? d : null;
      case EnumValueType.boolean_:
        if (value is bool) return value;
        if (value is int) return value != 0;
        if (value is String) {
          final lower = value.toLowerCase();
          if (['true', '1', 'yes', 'y'].contains(lower)) return true;
          if (['false', '0', 'no', 'n'].contains(lower)) return false;
        }
        return null;
      case EnumValueType.string_:
        return value.toString();
      case EnumValueType.stringIgnoreCase_:
        return value.toString().toLowerCase();
      case EnumValueType.decimal_:
      case EnumValueType.rational_:
        // 変換できない値は null として扱い、末尾に並べます。
        try {
          return UtilPortableNumeric.convert(value, vType);
        } catch (_) {
          return null;
        }
      case EnumValueType.auto_:
        // そのまま返します。
        return value;
    }
  }

  @override
  Comparator<Map<String, dynamic>> getComparator() {
    return (Map<String, dynamic> a, Map<String, dynamic> b) {
      // 型変換を適用
      dynamic aValue = _convertValue(UtilField.getNestedFieldValue(a, field));
      dynamic bValue = _convertValue(UtilField.getNestedFieldValue(b, field));
      // A naive datetime compared with an aware one is
      // treated as null, the same as the Python version.
      if (aValue is NaiveOrUtc && bValue is NaiveOrUtc) {
        if (!aValue.isNaive && bValue.isNaive) {
          bValue = null;
        } else if (aValue.isNaive && !bValue.isNaive) {
          aValue = null;
        }
      }
      if (aValue is NaiveOrUtc) aValue = aValue.value;
      if (bValue is NaiveOrUtc) bValue = bValue.value;
      // null値対応用の処理。
      // 両方nullなら同等
      if (aValue == null && bValue == null) return 0;
      // 一方がnullならnullを後に送る（昇順時）
      if (aValue == null) return reversed ? -1 : 1;
      if (bValue == null) return reversed ? 1 : -1;
      // 比較用の計算。
      int result = 0;
      switch (vType) {
        // 型指定での特殊処理
        case EnumValueType.floatEpsilon12_:
          final diff = (aValue as double) - (bValue as double);
          if (diff.abs() < 1e-12) {
            result = 0;
          } else {
            result = diff < 0 ? -1 : 1;
          }
          break;
        default:
          if (aValue is bool && bValue is bool) {
            final int aInt = aValue ? 1 : 0;
            final int bInt = bValue ? 1 : 0;
            result = aInt.compareTo(bInt);
          } else if (aValue is Comparable && bValue is Comparable) {
            if (aValue.runtimeType != bValue.runtimeType) {
              throw Exception('Incompatible types');
            }
            result = aValue.compareTo(bValue);
          } else {
            throw Exception('Field not comparable');
          }
      }
      return reversed ? -result : result;
    };
  }
}
