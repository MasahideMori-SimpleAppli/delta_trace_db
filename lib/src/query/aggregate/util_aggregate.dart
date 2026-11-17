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
    if (a.field != null && a.fields != null) {
      throw ArgumentError("Specify either field or fields, not both.");
    }
    if (a.fields != null && a.fields!.isEmpty) {
      throw ArgumentError("fields must not be empty.");
    }
    final List<String>? paths =
        a.fields ?? (a.field != null ? [a.field!] : null);
    if (a.type == EnumAggregateType.count_) {
      if (paths == null) return items.length;
      return items
          .where(
            (e) =>
                paths.every((p) => UtilField.getNestedFieldValue(e, p) != null),
          )
          .length;
    }
    if (paths == null) {
      throw ArgumentError("${a.type.name} requires a field.");
    }
    switch (a.vType) {
      case EnumValueType.floatStrict_:
        return _calculateFloat(
          _values<double>(items, a, paths, _toDouble, (x, y) => x * y),
          a.type,
        );
      case EnumValueType.decimal_:
        return _calculateExact(
          _values<Comparable<dynamic>>(
            items,
            a,
            paths,
            (v) => UtilPortableNumeric.convert(v, a.vType),
            (x, y) => (x as PortableDecimal) * (y as PortableDecimal),
          ),
          a,
        );
      case EnumValueType.rational_:
        return _calculateExact(
          _values<Comparable<dynamic>>(
            items,
            a,
            paths,
            (v) => UtilPortableNumeric.convert(v, a.vType),
            (x, y) => (x as PortableRational) * (y as PortableRational),
          ),
          a,
        );
      default:
        throw ArgumentError(
          "${a.type.name} does not support vType ${a.vType.name}.",
        );
    }
  }

  /// (en) Converts the values of [paths] of each item and returns their
  /// products. Items with a null value in any of [paths] are skipped.
  ///
  /// (ja) 各アイテムの [paths] の値を変換し、その積を返します。
  /// [paths] のいずれかの値が null のアイテムは除外します。
  ///
  /// * [items] : The target items.
  /// * [a] : The aggregation.
  /// * [paths] : The field paths. One path for field.
  /// * [convert] : Converts a value.
  /// * [multiply] : Multiplies two converted values.
  ///
  /// Throws [ArgumentError] if a value cannot be converted.
  static List<T> _values<T>(
    List<Map<String, dynamic>> items,
    Aggregation a,
    List<String> paths,
    T Function(Object value) convert,
    T Function(T x, T y) multiply,
  ) {
    final List<T> r = [];
    for (final Map<String, dynamic> item in items) {
      final List<dynamic> raw = [
        for (final String p in paths) UtilField.getNestedFieldValue(item, p),
      ];
      if (raw.contains(null)) continue;
      T? product;
      for (var i = 0; i < paths.length; i++) {
        final T c;
        try {
          c = convert(raw[i] as Object);
        } catch (_) {
          throw ArgumentError(
            "Cannot convert the value of field '${paths[i]}' "
            "to ${a.vType.name}.",
          );
        }
        product = product == null ? c : multiply(product, c);
      }
      r.add(product as T);
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
