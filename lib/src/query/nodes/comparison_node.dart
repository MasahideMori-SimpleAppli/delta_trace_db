import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:delta_trace_db/src/query/util_field.dart';

/// (en) Query node for Equals operation.
///
/// (ja) Equals演算のためのクエリノード。
class FieldEquals extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;

  /// Query node for Equals (filed == value) operation.
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  FieldEquals(this.field, this.value, {this.vType = EnumValueType.auto_}) {
    if (value is DateTime) {
      vType = EnumValueType.datetime_;
    }
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
          return DateTime.parse(fValue.toString()) == (value as DateTime);
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
        case EnumValueType.string_:
          return fValue.toString() == value.toString();
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.equals_.name,
    'field': field,
    'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
    'vType': vType.name,
    'version': '2',
  };
}

/// (en) Query node for NotEquals operation.
///
/// (ja) NotEquals演算のためのクエリノード。
class FieldNotEquals extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;

  /// Query node for NotEquals (filed != value) operation.
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  FieldNotEquals(this.field, this.value, {this.vType = EnumValueType.auto_}) {
    if (value is DateTime) {
      vType = EnumValueType.datetime_;
    }
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
          return DateTime.parse(fValue.toString()) != (value as DateTime);
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
        case EnumValueType.string_:
          return fValue.toString() != value.toString();
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.notEquals_.name,
    'field': field,
    'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
    'vType': vType.name,
    'version': '2',
  };
}

/// (en) Query node for "field > value" operation.
///
/// (ja) "field > value" 演算のためのクエリノード。
class FieldGreaterThan extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;

  /// Query node for "field > value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  FieldGreaterThan(this.field, this.value, {this.vType = EnumValueType.auto_}) {
    if (value is DateTime) {
      vType = EnumValueType.datetime_;
    }
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
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          return DateTime.parse(fValue.toString()).isAfter(value as DateTime);
        case EnumValueType.int_:
          return int.parse(fValue.toString()) > int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) >
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final a = double.parse(fValue.toString());
          final b = double.parse(value.toString());
          return (a - b) > 1e-12;
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) > 0;
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
    'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
    'vType': vType.name,
    'version': '2',
  };
}

/// (en) Query node for "field < value" operation.
///
/// (ja) "field < value" 演算のためのクエリノード。
class FieldLessThan extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;

  /// Query node for "field < value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  FieldLessThan(this.field, this.value, {this.vType = EnumValueType.auto_}) {
    if (value is DateTime) {
      vType = EnumValueType.datetime_;
    }
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
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          return DateTime.parse(fValue.toString()).isBefore(value as DateTime);
        case EnumValueType.int_:
          return int.parse(fValue.toString()) < int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) <
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final double a = double.parse(fValue.toString());
          final double b = double.parse(value.toString());
          return (b - a) > 1e-12;
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) < 0;
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
    'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
    'vType': vType.name,
    'version': '2',
  };
}

/// (en) Query node for "field >= value" operation.
///
/// (ja) "field >= value" 演算のためのクエリノード。
class FieldGreaterThanOrEqual extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;

  /// Query node for "field >= value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  FieldGreaterThanOrEqual(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
  }) {
    if (value is DateTime) {
      vType = EnumValueType.datetime_;
    }
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
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          final d = DateTime.parse(fValue.toString());
          return !d.isBefore(value as DateTime); // d1 >= d2
        case EnumValueType.int_:
          return int.parse(fValue.toString()) >= int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) >=
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final a = double.parse(fValue.toString());
          final b = double.parse(value.toString());
          return (a - b) >= -1e-12; // a >= b（誤差付き）
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) >= 0;
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
    'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
    'vType': vType.name,
    'version': '2',
  };
}

/// (en) Query node for "field <= value" operation.
///
/// (ja) "field <= value" 演算のためのクエリノード。
class FieldLessThanOrEqual extends QueryNode {
  final String field;
  final dynamic value;
  EnumValueType vType;

  /// Query node for "field <= value" operation.
  /// If you try to compare objects that cannot be compared in magnitude,
  /// such as null or bool, the result will always be False.
  ///
  /// * [field] : The target variable name.
  /// * [value] : The compare value.
  /// If DateTime is specified, it will be automatically converted to
  /// Iso8601String and vType will be set to EnumValueType.datetime_.
  /// * [vType] : Specifies the comparison type during calculation.
  /// If you select anything other than auto_,
  /// the value will be cast to that type before the comparison is performed.
  /// When an exception occurs, such as a conversion failure,
  /// the result is always False.
  FieldLessThanOrEqual(
    this.field,
    this.value, {
    this.vType = EnumValueType.auto_,
  }) {
    if (value is DateTime) {
      vType = EnumValueType.datetime_;
    }
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
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) {
    final fValue = UtilField.getNestedFieldValue(data, field);
    if (fValue == null || value == null) return false;
    try {
      switch (vType) {
        case EnumValueType.datetime_:
          final d = DateTime.parse(fValue.toString());
          return !d.isAfter(value as DateTime); // d1 <= d2
        case EnumValueType.int_:
          return int.parse(fValue.toString()) <= int.parse(value.toString());
        case EnumValueType.floatStrict_:
          return double.parse(fValue.toString()) <=
              double.parse(value.toString());
        case EnumValueType.floatEpsilon12_:
          final a = double.parse(fValue.toString());
          final b = double.parse(value.toString());
          return (b - a) >= -1e-12; // a <= b（誤差を含めて）
        case EnumValueType.string_:
          return fValue.toString().compareTo(value.toString()) <= 0;
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
    'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
    'vType': vType.name,
    'version': '2',
  };
}

/// (en) Query node for "RegExp(pattern).hasMatch(field)" operation.
///
/// (ja) "RegExp(pattern).hasMatch(field)" 演算のためのクエリノード。
class FieldMatchesRegex extends QueryNode {
  final String field;
  final String pattern;

  /// Query node for "RegExp(pattern).hasMatch(field)" operation.
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

  /// Query node for "field.contains(value)" operation.
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

  /// Query node for "values.contains(field)" operation.
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
  final Iterable<dynamic> values;

  /// Query node for "Not values.contains(field)" operation.
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
    'values': values.toList(),
    'version': '1',
  };
}

/// (en) Query node for "field.toString().startsWidth(value)" operation.
///
/// (ja) "field.toString().startsWidth(value)" 演算のためのクエリノード。
class FieldStartsWith extends QueryNode {
  final String field;
  final String value;

  /// Query node for "field.toString().startsWidth(value)" operation.
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

  /// Query node for "field.toString().endsWidth(value)" operation.
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
