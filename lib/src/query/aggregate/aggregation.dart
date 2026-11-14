import 'package:file_state_manager/file_state_manager.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) A definition of one aggregation in an aggregate query.
///
/// (ja) aggregateクエリにおける、1つの集計の定義です。
class Aggregation extends CloneableFile {
  static const String className = "Aggregation";
  static const String version = "1";

  final EnumAggregateType type;
  final String? field;
  final EnumValueType vType;
  final String? alias;
  final int? scale;
  final EnumRoundingMode? rounding;

  /// (en) A definition of one aggregation in an aggregate query.
  ///
  /// (ja) aggregateクエリにおける、1つの集計の定義です。
  ///
  /// * [type] : The aggregation type.
  /// * [field] : The target field name. Nested fields can be specified with
  /// dot notation. Required except for count_. For count_, if specified,
  /// only items whose field value is not null are counted.
  /// Null and missing values are always excluded from the calculation.
  /// * [vType] : The calculation type for sum_, min_, max_ and mean_.
  /// Only EnumValueType.floatStrict_, EnumValueType.decimal_ and
  /// EnumValueType.rational_ are supported. Ignored by count_.
  ///   - floatStrict_: Calculated with double. Numbers and plain number
  ///   strings are converted. The result is a double.
  ///   - decimal_: Calculated exactly. Only Strings and PortableDecimal are
  ///   converted. The result is a String.
  ///   - rational_: Calculated exactly. Only Strings, PortableDecimal and
  ///   PortableRational are converted. The result is a String.
  /// If a value cannot be converted, the query fails.
  /// * [alias] : The key of this result in the result map.
  /// If null, "{type name}{field}" is used (e.g. "sum_price"),
  /// or "count_" for count_ without a field.
  /// * [scale] : Used only for mean_ with decimal_, and required for it.
  /// The number of digits after the decimal point of the result.
  /// * [rounding] : Used only for mean_ with decimal_, and required for it.
  /// The rounding mode of the result.
  Aggregation(
    this.type, {
    this.field,
    this.vType = EnumValueType.floatStrict_,
    this.alias,
    this.scale,
    this.rounding,
  });

  /// (en) The key of this result in the result map.
  ///
  /// (ja) 結果のマップにおける、この集計結果のキーです。
  String get outputKey => alias ?? "${type.name}${field ?? ""}";

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory Aggregation.fromDict(Map<String, dynamic> src) {
    return Aggregation(
      EnumAggregateType.values.byName(src["type"]),
      field: src["field"],
      vType: EnumValueType.values.byName(src["vType"]),
      alias: src["alias"],
      scale: src["scale"],
      rounding: src["rounding"] != null
          ? EnumRoundingMode.values.byName(src["rounding"])
          : null,
    );
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "type": type.name,
      "field": field,
      "vType": vType.name,
      "alias": alias,
      "scale": scale,
      "rounding": rounding?.name,
    };
  }

  @override
  Aggregation clone() {
    return Aggregation.fromDict(toDict());
  }
}
