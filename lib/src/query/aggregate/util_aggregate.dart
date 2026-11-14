import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:delta_trace_db/src/query/util_field.dart';
import 'package:delta_trace_db/src/query/util_portable_numeric.dart';

/// Plain number strings accepted by floatStrict_ aggregation.
/// The same pattern is used in the Python version so that both accept
/// exactly the same strings.
final RegExp _floatPattern = RegExp(
  r'^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][+-]?[0-9]+)?$',
);

/// (en) Utilities for calculating aggregate queries.
/// The results are identical to the Python version.
///
/// (ja) aggregateクエリの計算用ユーティリティです。
/// 計算結果はPython版と同一になります。
class UtilAggregate {
  /// (en) Calculates all aggregations for the items.
  ///
  /// (ja) 対象のアイテムについて、すべての集計を計算します。
  ///
  /// * [items] : The target items.
  /// * [aggregations] : The aggregation definitions.
  ///
  /// Returns a map whose keys are Aggregation.outputKey.
  /// Throws [ArgumentError] if a definition is invalid or a value cannot be
  /// converted.
  static Map<String, dynamic> calculate(
    List<Map<String, dynamic>> items,
    List<Aggregation> aggregations,
  ) {
    final Map<String, dynamic> r = {};
    for (final Aggregation a in aggregations) {
      final String key = a.outputKey;
      if (r.containsKey(key)) {
        throw ArgumentError("Duplicate aggregation key: $key");
      }
      r[key] = _calculateOne(items, a);
    }
    return r;
  }

  static dynamic _calculateOne(
    List<Map<String, dynamic>> items,
    Aggregation a,
  ) {
    if (a.type == EnumAggregateType.count_) {
      if (a.field == null) return items.length;
      return items
          .where((e) => UtilField.getNestedFieldValue(e, a.field!) != null)
          .length;
    }
    if (a.field == null) {
      throw ArgumentError("${a.type.name} requires a field.");
    }
    switch (a.vType) {
      case EnumValueType.floatStrict_:
        return _calculateFloat(_values(items, a, _toDouble), a.type);
      case EnumValueType.decimal_:
      case EnumValueType.rational_:
        return _calculateExact(
          _values(items, a, (v) => UtilPortableNumeric.convert(v, a.vType)),
          a,
        );
      default:
        throw ArgumentError(
          "${a.type.name} does not support vType ${a.vType.name}.",
        );
    }
  }

  /// Converts the non-null field values. Throws ArgumentError on failure.
  static List<T> _values<T>(
    List<Map<String, dynamic>> items,
    Aggregation a,
    T Function(Object value) convert,
  ) {
    final List<T> r = [];
    for (final Map<String, dynamic> item in items) {
      final dynamic v = UtilField.getNestedFieldValue(item, a.field!);
      if (v == null) continue;
      try {
        r.add(convert(v));
      } catch (_) {
        throw ArgumentError(
          "Cannot convert the value of field '${a.field}' "
          "to ${a.vType.name}: $v",
        );
      }
    }
    return r;
  }

  static double _toDouble(Object v) {
    if (v is bool) throw const FormatException();
    if (v is num) {
      final double d = v.toDouble();
      if (!d.isFinite) throw const FormatException();
      return d;
    }
    if (v is String && _floatPattern.hasMatch(v)) {
      final double d = double.parse(v);
      if (!d.isFinite) throw const FormatException();
      return d;
    }
    throw const FormatException();
  }

  static double? _calculateFloat(List<double> values, EnumAggregateType t) {
    if (t == EnumAggregateType.sum_ || t == EnumAggregateType.mean_) {
      // Simple left-to-right addition, the same as the Python version.
      double sum = 0.0;
      for (final double v in values) {
        sum += v;
      }
      if (t == EnumAggregateType.sum_) return sum;
      return values.isEmpty ? null : sum / values.length;
    }
    if (values.isEmpty) return null;
    double r = values.first;
    for (final double v in values) {
      if (t == EnumAggregateType.min_ ? v < r : v > r) r = v;
    }
    return r;
  }

  static String? _calculateExact(
    List<Comparable<dynamic>> values,
    Aggregation a,
  ) {
    final bool isDecimal = a.vType == EnumValueType.decimal_;
    switch (a.type) {
      case EnumAggregateType.sum_:
      case EnumAggregateType.mean_:
        if (a.type == EnumAggregateType.mean_ && isDecimal) {
          if (a.scale == null || a.rounding == null) {
            throw ArgumentError(
              "mean_ with decimal_ requires scale and rounding.",
            );
          }
          if (a.scale! < 0) {
            throw ArgumentError("scale must be 0 or more.");
          }
        }
        if (isDecimal) {
          PortableDecimal sum = PortableDecimal.fromInt(0);
          for (final v in values) {
            sum += v as PortableDecimal;
          }
          if (a.type == EnumAggregateType.sum_) return sum.toString();
          if (values.isEmpty) return null;
          return sum
              .divide(
                PortableDecimal.fromInt(values.length),
                a.scale!,
                a.rounding!,
              )
              .toString();
        }
        PortableRational sum = PortableRational.fromInt(0);
        for (final v in values) {
          sum += v as PortableRational;
        }
        if (a.type == EnumAggregateType.sum_) return sum.toString();
        if (values.isEmpty) return null;
        return (sum / PortableRational.fromInt(values.length)).toString();
      case EnumAggregateType.min_:
      case EnumAggregateType.max_:
        if (values.isEmpty) return null;
        Comparable<dynamic> r = values.first;
        for (final v in values) {
          final int c = v.compareTo(r);
          if (a.type == EnumAggregateType.min_ ? c < 0 : c > 0) r = v;
        }
        return r.toString();
      case EnumAggregateType.count_:
        throw StateError("unreachable");
    }
  }
}
