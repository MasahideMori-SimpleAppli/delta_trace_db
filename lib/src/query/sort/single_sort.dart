import 'package:file_state_manager/file_state_manager.dart';
import 'package:delta_trace_db/src/query/util_field.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) This class allows you to specify single-key sorting for
/// the return values of a query.
///
/// (ja) クエリの戻り値について、単一キーでのソートを指定するためのクラスです。
class SingleSort extends CloneableFile implements AbstractSort {
  static const String className = "SingleSort";
  static const String version = "4";
  String field;
  bool reversed;
  EnumValueType vType;

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
  /// If an exception occurs, such as a conversion failure,
  /// an Exception is thrown.
  SingleSort({
    required this.field,
    this.reversed = false,
    this.vType = EnumValueType.auto_,
  });

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
  dynamic _convertValue(dynamic value) {
    if (value == null) return null;
    switch (vType) {
      case EnumValueType.datetime_:
        if (value is DateTime) return value;
        if (value is String) return DateTime.tryParse(value);
        throw Exception('Cannot convert value to DateTime');
      case EnumValueType.int_:
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
        throw Exception('Cannot convert value to int');
      case EnumValueType.floatStrict_:
        if (value is double) return value;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
        throw Exception('Cannot convert value to double');
      case EnumValueType.floatEpsilon12_:
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
        throw Exception('Cannot convert value to double (epsilon)');
      case EnumValueType.boolean_:
        if (value is bool) return value;
        if (value is int) return value != 0;
        if (value is String) {
          final lower = value.toLowerCase();
          if (['true', '1', 'yes', 'y'].contains(lower)) return true;
          if (['false', '0', 'no', 'n'].contains(lower)) return false;
        }
        throw Exception('Cannot convert value to bool');
      case EnumValueType.string_:
        return value.toString();
      case EnumValueType.auto_:
        // そのまま返します。
        return value;
    }
  }

  @override
  Comparator<Map<String, dynamic>> getComparator() {
    return (Map<String, dynamic> a, Map<String, dynamic> b) {
      // 型変換を適用
      final aValue = _convertValue(UtilField.getNestedFieldValue(a, field));
      final bValue = _convertValue(UtilField.getNestedFieldValue(b, field));
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
