import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:delta_trace_db/src/query/util_field.dart';
import 'package:delta_trace_db/src/query/util_date_time.dart';
import 'package:delta_trace_db/src/query/util_portable_numeric.dart';

/// Returns the field value and the compare value for datetime_ comparison
/// as UTC DateTimes, without converting them to the local time of the
/// running machine.
/// If [naiveUtcOffsetMinutes] is not null, naive values are converted to UTC
/// with that offset. Otherwise, a FormatException is thrown if exactly one of
/// them is timezone-aware, so that mixing naive and aware datetimes is
/// treated as a conversion failure (false), the same as the Python version.
/// Naive values are then compared by their date and time as they are.
(DateTime, DateTime) _dateTimes(
  dynamic fValue,
  dynamic value,
  int? naiveUtcOffsetMinutes,
) {
  final NaiveOrUtc? d = UtilDateTime.tryParse(fValue.toString());
  if (d == null || value is! DateTime) {
    throw const FormatException("Invalid date-time.");
  }
  final NaiveOrUtc v = UtilDateTime.fromDateTime(value);
  if (naiveUtcOffsetMinutes != null) {
    return (
      UtilDateTime.toUtc(d, naiveUtcOffsetMinutes),
      UtilDateTime.toUtc(v, naiveUtcOffsetMinutes),
    );
  }
  if (d.isNaive != v.isNaive) {
    throw const FormatException(
      "Naive and aware datetimes cannot be compared.",
    );
  }
  return (d.value, v.value);
}

/// (en) Query node for Equals operation.
///
/// (ja) Equals演算のためのクエリノード。
class FieldEquals extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;
  final int? naiveUtcOffsetMinutes;

  /// (en) Query node for Equals (filed == value) operation.
  ///
  /// (ja) Equals (filed == value) 判定のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// If PortableDecimal or PortableRational is specified, it will be saved as
  /// a String and vType will be set to EnumValueType.decimal_ or
  /// EnumValueType.rational_. With these types, only String, PortableDecimal
  /// and PortableRational values are converted; numbers such as int and double
  /// are treated as conversion failures.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  /// With datetime_, mixing a timezone-aware (UTC) value and a naive (local)
  /// value is treated as a conversion failure.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before comparison,
  /// so aware and naive values can be compared. Must be greater than -1440
  /// and less than 1440.
  FieldEquals(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    vType = UtilPortableNumeric.inferVType(value, vType);
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldEquals.fromDict(Map<String, dynamic> src) {
    final EnumValueType t = EnumValueType.values.byName(src['vType']);
    return FieldEquals(
      src['field'],
      t == EnumValueType.datetime_
          ? DateTime.parse(src['value'])
          : src['value'],
      vType: t,
      naiveUtcOffsetMinutes: src['naiveUtcOffsetMinutes'],
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    try {
      switch (vType) {
        case EnumValueType.auto_:
          return fValue == value;
        case EnumValueType.datetime_:
          final (d, v) = _dateTimes(fValue, value, naiveUtcOffsetMinutes);
          return d == v;
        case EnumValueType.int_:
          return int.parse(fValue.toString()) == int.parse(value.toString());
        case EnumValueType.floatStrict_:
          final double a = double.parse(fValue.toString());
          final double b = double.parse(value.toString());
          return a == b;
        case EnumValueType.floatEpsilon12_:
          final double a = double.parse(fValue.toString());
          final double b = double.parse(value.toString());
          return (a - b).abs() < 1e-12;
        case EnumValueType.boolean_:
          return bool.parse(fValue.toString().toLowerCase()) ==
              bool.parse(value.toString().toLowerCase());
        case EnumValueType.decimal_:
        case EnumValueType.rational_:
          return UtilPortableNumeric.compare(fValue, value, vType) == 0;
        case EnumValueType.string_:
          return fValue.toString() == value.toString();
        case EnumValueType.stringIgnoreCase_:
          return fValue.toString().toLowerCase() ==
              value.toString().toLowerCase();
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.equals_.name,
    'field': field,
    'value': value is DateTime
        ? (value as DateTime).toIso8601String()
        : UtilPortableNumeric.toSerializable(value),
    'vType': vType.name,
    'naiveUtcOffsetMinutes': naiveUtcOffsetMinutes,
    'version': '3',
  };
}

/// (en) Query node for NotEquals operation.
///
/// (ja) NotEquals演算のためのクエリノード。
class FieldNotEquals extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;
  final int? naiveUtcOffsetMinutes;

  /// (en) Query node for NotEquals (filed != value) operation.
  ///
  /// (ja) NotEquals (filed != value) 判定のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// If PortableDecimal or PortableRational is specified, it will be saved as
  /// a String and vType will be set to EnumValueType.decimal_ or
  /// EnumValueType.rational_. With these types, only String, PortableDecimal
  /// and PortableRational values are converted; numbers such as int and double
  /// are treated as conversion failures.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  /// With datetime_, mixing a timezone-aware (UTC) value and a naive (local)
  /// value is treated as a conversion failure.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before comparison,
  /// so aware and naive values can be compared. Must be greater than -1440
  /// and less than 1440.
  FieldNotEquals(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    vType = UtilPortableNumeric.inferVType(value, vType);
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldNotEquals.fromDict(Map<String, dynamic> src) {
    final EnumValueType t = EnumValueType.values.byName(src['vType']);
    return FieldNotEquals(
      src['field'],
      t == EnumValueType.datetime_
          ? DateTime.parse(src['value'])
          : src['value'],
      vType: t,
      naiveUtcOffsetMinutes: src['naiveUtcOffsetMinutes'],
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    try {
      switch (vType) {
        case EnumValueType.auto_:
          return fValue != value;
        case EnumValueType.datetime_:
          final (d, v) = _dateTimes(fValue, value, naiveUtcOffsetMinutes);
          return d != v;
        case EnumValueType.int_:
          return int.parse(fValue.toString()) != int.parse(value.toString());
        case EnumValueType.floatStrict_:
          final double a = double.parse(fValue.toString());
          final double b = double.parse(value.toString());
          return a != b;
        case EnumValueType.floatEpsilon12_:
          final double a = double.parse(fValue.toString());
          final double b = double.parse(value.toString());
          return (a - b).abs() >= 1e-12;
        case EnumValueType.boolean_:
          return bool.parse(fValue.toString().toLowerCase()) !=
              bool.parse(value.toString().toLowerCase());
        case EnumValueType.decimal_:
        case EnumValueType.rational_:
          return UtilPortableNumeric.compare(fValue, value, vType) != 0;
        case EnumValueType.string_:
          return fValue.toString() != value.toString();
        case EnumValueType.stringIgnoreCase_:
          return fValue.toString().toLowerCase() !=
              value.toString().toLowerCase();
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.notEquals_.name,
    'field': field,
    'value': value is DateTime
        ? (value as DateTime).toIso8601String()
        : UtilPortableNumeric.toSerializable(value),
    'vType': vType.name,
    'naiveUtcOffsetMinutes': naiveUtcOffsetMinutes,
    'version': '3',
  };
}

/// (en) Query node for "field > value" operation.
///
/// (ja) "field > value" 演算のためのクエリノード。
class FieldGreaterThan extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;
  final int? naiveUtcOffsetMinutes;

  /// (en) Query node for "field > value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// (ja) "field > value" 判定のためのクエリノード。
  /// null や bool など、大小比較できないオブジェクトを比較しようとすると、
  /// 結果は常に False になります。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// If PortableDecimal or PortableRational is specified, it will be saved as
  /// a String and vType will be set to EnumValueType.decimal_ or
  /// EnumValueType.rational_. With these types, only String, PortableDecimal
  /// and PortableRational values are converted; numbers such as int and double
  /// are treated as conversion failures.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  /// With datetime_, mixing a timezone-aware (UTC) value and a naive (local)
  /// value is treated as a conversion failure.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before comparison,
  /// so aware and naive values can be compared. Must be greater than -1440
  /// and less than 1440.
  FieldGreaterThan(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    vType = UtilPortableNumeric.inferVType(value, vType);
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldGreaterThan.fromDict(Map<String, dynamic> src) {
    final EnumValueType t = EnumValueType.values.byName(src['vType']);
    return FieldGreaterThan(
      src['field'],
      t == EnumValueType.datetime_
          ? DateTime.parse(src['value'])
          : src['value'],
      vType: t,
      naiveUtcOffsetMinutes: src['naiveUtcOffsetMinutes'],
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          final (d, v) = _dateTimes(fValue, value, naiveUtcOffsetMinutes);
          return d.isAfter(v);
        case EnumValueType.int_:
          return int.parse(fValue.toString()) > int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) >
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final a = double.parse(fValue.toString());
          final b = double.parse(value.toString());
          return (a - b) > 1e-12;
        case EnumValueType.decimal_:
        case EnumValueType.rational_:
          return UtilPortableNumeric.compare(fValue, value, vType) > 0;
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) > 0;
        case EnumValueType.stringIgnoreCase_:
          return fValue.toString().toLowerCase().compareTo(
                value.toString().toLowerCase(),
              ) >
              0;
        case EnumValueType.auto_:
          return fValue > value;
        case EnumValueType.boolean_:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.greaterThan_.name,
    'field': field,
    'value': value is DateTime
        ? (value as DateTime).toIso8601String()
        : UtilPortableNumeric.toSerializable(value),
    'vType': vType.name,
    'naiveUtcOffsetMinutes': naiveUtcOffsetMinutes,
    'version': '3',
  };
}

/// (en) Query node for "field < value" operation.
///
/// (ja) "field < value" 演算のためのクエリノード。
class FieldLessThan extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;
  final int? naiveUtcOffsetMinutes;

  /// (en) Query node for "field < value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// (ja) "field < value" 判定のためのクエリノード。
  /// null や bool など、大小比較できないオブジェクトを比較しようとすると、
  /// 結果は常に False になります。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// If PortableDecimal or PortableRational is specified, it will be saved as
  /// a String and vType will be set to EnumValueType.decimal_ or
  /// EnumValueType.rational_. With these types, only String, PortableDecimal
  /// and PortableRational values are converted; numbers such as int and double
  /// are treated as conversion failures.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  /// With datetime_, mixing a timezone-aware (UTC) value and a naive (local)
  /// value is treated as a conversion failure.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before comparison,
  /// so aware and naive values can be compared. Must be greater than -1440
  /// and less than 1440.
  FieldLessThan(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    vType = UtilPortableNumeric.inferVType(value, vType);
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldLessThan.fromDict(Map<String, dynamic> src) {
    final EnumValueType t = EnumValueType.values.byName(src['vType']);
    return FieldLessThan(
      src['field'],
      t == EnumValueType.datetime_
          ? DateTime.parse(src['value'])
          : src['value'],
      vType: t,
      naiveUtcOffsetMinutes: src['naiveUtcOffsetMinutes'],
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          final (d, v) = _dateTimes(fValue, value, naiveUtcOffsetMinutes);
          return d.isBefore(v);
        case EnumValueType.int_:
          return int.parse(fValue.toString()) < int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) <
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final double a = double.parse(fValue.toString());
          final double b = double.parse(value.toString());
          return (b - a) > 1e-12;
        case EnumValueType.decimal_:
        case EnumValueType.rational_:
          return UtilPortableNumeric.compare(fValue, value, vType) < 0;
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) < 0;
        case EnumValueType.stringIgnoreCase_:
          return fValue.toString().toLowerCase().compareTo(
                value.toString().toLowerCase(),
              ) <
              0;
        case EnumValueType.auto_:
          return fValue < value;
        case EnumValueType.boolean_:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.lessThan_.name,
    'field': field,
    'value': value is DateTime
        ? (value as DateTime).toIso8601String()
        : UtilPortableNumeric.toSerializable(value),
    'vType': vType.name,
    'naiveUtcOffsetMinutes': naiveUtcOffsetMinutes,
    'version': '3',
  };
}

/// (en) Query node for "field >= value" operation.
///
/// (ja) "field >= value" 演算のためのクエリノード。
class FieldGreaterThanOrEqual extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;
  final int? naiveUtcOffsetMinutes;

  /// (en) Query node for "field >= value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// (ja) "field >= value" 判定のためのクエリノード。
  /// null や bool など、大小比較できないオブジェクトを比較しようとすると、
  /// 結果は常に False になります。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// If PortableDecimal or PortableRational is specified, it will be saved as
  /// a String and vType will be set to EnumValueType.decimal_ or
  /// EnumValueType.rational_. With these types, only String, PortableDecimal
  /// and PortableRational values are converted; numbers such as int and double
  /// are treated as conversion failures.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  /// With datetime_, mixing a timezone-aware (UTC) value and a naive (local)
  /// value is treated as a conversion failure.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before comparison,
  /// so aware and naive values can be compared. Must be greater than -1440
  /// and less than 1440.
  FieldGreaterThanOrEqual(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    vType = UtilPortableNumeric.inferVType(value, vType);
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldGreaterThanOrEqual.fromDict(Map<String, dynamic> src) {
    final EnumValueType t = EnumValueType.values.byName(src['vType']);
    return FieldGreaterThanOrEqual(
      src['field'],
      t == EnumValueType.datetime_
          ? DateTime.parse(src['value'])
          : src['value'],
      vType: t,
      naiveUtcOffsetMinutes: src['naiveUtcOffsetMinutes'],
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          final (d, v) = _dateTimes(fValue, value, naiveUtcOffsetMinutes);
          return !d.isBefore(v); // d1 >= d2
        case EnumValueType.int_:
          return int.parse(fValue.toString()) >= int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) >=
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final a = double.parse(fValue.toString());
          final b = double.parse(value.toString());
          return (a - b) >= -1e-12; // a >= b（誤差付き）
        case EnumValueType.decimal_:
        case EnumValueType.rational_:
          return UtilPortableNumeric.compare(fValue, value, vType) >= 0;
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) >= 0;
        case EnumValueType.stringIgnoreCase_:
          return fValue.toString().toLowerCase().compareTo(
                value.toString().toLowerCase(),
              ) >=
              0;
        case EnumValueType.auto_:
          return fValue >= value;
        case EnumValueType.boolean_:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.greaterThanOrEqual_.name,
    'field': field,
    'value': value is DateTime
        ? (value as DateTime).toIso8601String()
        : UtilPortableNumeric.toSerializable(value),
    'vType': vType.name,
    'naiveUtcOffsetMinutes': naiveUtcOffsetMinutes,
    'version': '3',
  };
}

/// (en) Query node for "field <= value" operation.
///
/// (ja) "field <= value" 演算のためのクエリノード。
class FieldLessThanOrEqual extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;
  final int? naiveUtcOffsetMinutes;

  /// (en) Query node for "field <= value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// (ja) "field <= value" 判定のためのクエリノード。
  /// null や bool など、大小比較できないオブジェクトを比較しようとすると、
  /// 結果は常に False になります。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// If PortableDecimal or PortableRational is specified, it will be saved as
  /// a String and vType will be set to EnumValueType.decimal_ or
  /// EnumValueType.rational_. With these types, only String, PortableDecimal
  /// and PortableRational values are converted; numbers such as int and double
  /// are treated as conversion failures.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  /// With datetime_, mixing a timezone-aware (UTC) value and a naive (local)
  /// value is treated as a conversion failure.
  /// * [naiveUtcOffsetMinutes] : Used only with datetime_. If specified,
  /// naive (local) date-times are interpreted as times at UTC + this many
  /// minutes (e.g. 540 for UTC+9) and converted to UTC before comparison,
  /// so aware and naive values can be compared. Must be greater than -1440
  /// and less than 1440.
  FieldLessThanOrEqual(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
    this.naiveUtcOffsetMinutes,
  }) {
    vType = UtilPortableNumeric.inferVType(value, vType);
    UtilDateTime.checkOffset(naiveUtcOffsetMinutes);
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldLessThanOrEqual.fromDict(Map<String, dynamic> src) {
    final EnumValueType t = EnumValueType.values.byName(src['vType']);
    return FieldLessThanOrEqual(
      src['field'],
      t == EnumValueType.datetime_
          ? DateTime.parse(src['value'])
          : src['value'],
      vType: t,
      naiveUtcOffsetMinutes: src['naiveUtcOffsetMinutes'],
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          final (d, v) = _dateTimes(fValue, value, naiveUtcOffsetMinutes);
          return !d.isAfter(v); // d1 <= d2
        case EnumValueType.int_:
          return int.parse(fValue.toString()) <= int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) <=
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final a = double.parse(fValue.toString());
          final b = double.parse(value.toString());
          return (b - a) >= -1e-12; // a <= b（誤差を含めて）
        case EnumValueType.decimal_:
        case EnumValueType.rational_:
          return UtilPortableNumeric.compare(fValue, value, vType) <= 0;
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) <= 0;
        case EnumValueType.stringIgnoreCase_:
          return fValue.toString().toLowerCase().compareTo(
                value.toString().toLowerCase(),
              ) <=
              0;
        case EnumValueType.auto_:
          return fValue <= value;
        case EnumValueType.boolean_:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.lessThanOrEqual_.name,
    'field': field,
    'value': value is DateTime
        ? (value as DateTime).toIso8601String()
        : UtilPortableNumeric.toSerializable(value),
    'vType': vType.name,
    'naiveUtcOffsetMinutes': naiveUtcOffsetMinutes,
    'version': '3',
  };
}

/// (en) Query node for "RegExp(pattern).hasMatch(field)" operation.
///
/// (ja) "RegExp(pattern).hasMatch(field)" 演算のためのクエリノード。
class FieldMatchesRegex extends QueryNode {
  final String field;
  final String pattern;

  /// (en) Query node for "RegExp(pattern).hasMatch(field)" operation.
  ///
  /// (ja) "RegExp(pattern).hasMatch(field)" 演算のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [pattern] : The compare pattern of regex.
  FieldMatchesRegex(this.field, this.pattern);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldMatchesRegex.fromDict(Map<String, dynamic> src) {
    return FieldMatchesRegex(src['field'], src['pattern']);
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final value = UtilField.getNestedFieldValue(data, field)?.toString();
    if (value == null) return false;
    return RegExp(pattern).hasMatch(value);
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.regex_.name,
    'field': field,
    'pattern': pattern,
    'version': '1',
  };
}

/// (en) Query node for "field.contains(value)" operation.
///
/// (ja) "field.contains(value)" 演算のためのクエリノード。
class FieldContains extends QueryNode {
  final String field;
  final dynamic value;

  /// (en) Query node for "field.contains(value)" operation.
  ///
  /// (ja) "field.contains(value)" 演算のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  FieldContains(this.field, this.value);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldContains.fromDict(Map<String, dynamic> src) {
    return FieldContains(src['field'], src['value']);
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final v = UtilField.getNestedFieldValue(data, field);
    if (v is Iterable) return v.contains(value);
    if (v is String && value is String) return v.contains(value);
    return false;
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.contains_.name,
    'field': field,
    'value': value,
    'version': '1',
  };
}

/// (en) Query node for "values.contains(field)" operation.
///
/// (ja) "values.contains(field)" 演算のためのクエリノード。
class FieldIn extends QueryNode {
  final String field;
  final List<dynamic> values;

  /// (en) Query node for "values.contains(field)" operation.
  ///
  /// (ja) "values.contains(field)" 演算のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [values] : The compare value.
  FieldIn(this.field, this.values);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldIn.fromDict(Map<String, dynamic> src) {
    return FieldIn(src['field'], List.from(src['values']));
  }

  @override
  bool evaluate(Map<String, dynamic> data) =>
      values.contains(UtilField.getNestedFieldValue(data, field));

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.in_.name,
    'field': field,
    'values': values,
    'version': '1',
  };
}

/// (en) Query node for "Not values.contains(field)" operation.
///
/// (ja) "Not values.contains(field)" 演算のためのクエリノード。
class FieldNotIn extends QueryNode {
  final String field;
  final List<dynamic> values;

  /// (en) Query node for "Not values.contains(field)" operation.
  ///
  /// (ja) "Not values.contains(field)" 演算のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  FieldNotIn(this.field, this.values);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldNotIn.fromDict(Map<String, dynamic> src) {
    return FieldNotIn(src['field'], List.from(src['values']));
  }

  @override
  bool evaluate(Map<String, dynamic> data) =>
      !values.contains(UtilField.getNestedFieldValue(data, field));

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.notIn_.name,
    'field': field,
    'values': values,
    'version': '2',
  };
}

/// (en) Query node for "field.toString().startsWidth(value)" operation.
///
/// (ja) "field.toString().startsWidth(value)" 演算のためのクエリノード。
class FieldStartsWith extends QueryNode {
  final String field;
  final String value;

  /// (en) Query node for "field.toString().startsWidth(value)" operation.
  ///
  /// (ja) "field.toString().startsWidth(value)" 演算のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  FieldStartsWith(this.field, this.value);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldStartsWith.fromDict(Map<String, dynamic> src) {
    return FieldStartsWith(src['field'], src['value']);
  }

  @override
  bool evaluate(Map<String, dynamic> data) =>
      UtilField.getNestedFieldValue(
        data,
        field,
      )?.toString().startsWith(value) ??
      false;

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.startsWith_.name,
    'field': field,
    'value': value,
    'version': '1',
  };
}

/// (en) Query node for "field.toString().endsWidth(value)" operation.
///
/// (ja) "field.toString().endsWidth(value)" 演算のためのクエリノード。
class FieldEndsWith extends QueryNode {
  final String field;
  final String value;

  /// (en) Query node for "field.toString().endsWidth(value)" operation.
  ///
  /// (ja) "field.toString().endsWidth(value)" 演算のためのクエリノード。
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  FieldEndsWith(this.field, this.value);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory FieldEndsWith.fromDict(Map<String, dynamic> src) {
    return FieldEndsWith(src['field'], src['value']);
  }

  @override
  bool evaluate(Map<String, dynamic> data) =>
      UtilField.getNestedFieldValue(data, field)?.toString().endsWith(value) ??
      false;

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.endsWith_.name,
    'field': field,
    'value': value,
    'version': '1',
  };
}
