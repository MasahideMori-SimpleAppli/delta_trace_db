import 'package:file_state_manager/file_state_manager.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) A definition of a key used to group items in an aggregate query.
/// Items with the same value (or the same period if [unit] is set) are
/// aggregated together, and each group becomes one result map that contains
/// the key value under [outputKey].
///
/// (ja) aggregateクエリでアイテムをグループ化するキーの定義です。
/// 同じ値（[unit] を指定した場合は同じ期間）のアイテムがまとめて集計され、
/// 各グループは、キーの値を [outputKey] に持つ1つの結果のマップになります。
class AggregateGroupKey extends CloneableFile {
  static const String className = "AggregateGroupKey";
  static const String version = "1";

  final String field;
  final EnumAggregateGroupUnit? unit;
  final int? utcOffsetMinutes;
  final int? weekStart;
  final int? startMonth;
  final String? alias;

  /// (en) A definition of a key used to group items in an aggregate query.
  ///
  /// (ja) aggregateクエリでアイテムをグループ化するキーの定義です。
  ///
  /// * [field] : The field whose value is used as the key.
  /// Nested fields and fields of joined items can be specified with dot
  /// notation. Items whose value is null or missing form a group whose key
  /// is null. Values are compared by their JSON representation,
  /// so 1 and "1" are different keys.
  /// * [unit] : If set, the value is read as an ISO 8601 date-time string
  /// (the same format as EnumValueType.datetime_) and the key is the label of
  /// the period that contains it. If the value cannot be read, the query fails.
  /// * [utcOffsetMinutes] : Used only with [unit]. The offset from UTC in
  /// minutes of the time zone in which the periods are divided
  /// (e.g. 540 for UTC+09:00). Values without a time zone are read as times
  /// in this time zone. Must be greater than -1440 and less than 1440.
  /// If null, 0 (UTC) is used.
  /// * [weekStart] : Used only with EnumAggregateGroupUnit.week.
  /// The first day of the week as an ISO 8601 weekday number
  /// (1 = Monday, ..., 7 = Sunday). If null, 1 (Monday) is used.
  /// * [startMonth] : Used only with EnumAggregateGroupUnit.quarter and
  /// EnumAggregateGroupUnit.year. The month in which the year starts (1-12),
  /// e.g. 4 for a fiscal year that starts in April. If null, 1 is used.
  /// * [alias] : The key of this value in the result map.
  /// If null, [field] is used.
  AggregateGroupKey(
    this.field, {
    this.unit,
    this.utcOffsetMinutes,
    this.weekStart,
    this.startMonth,
    this.alias,
  });

  /// (en) The key of this value in the result map.
  ///
  /// (ja) 結果のマップにおける、この値のキーです。
  String get outputKey => alias ?? field;

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory AggregateGroupKey.fromDict(Map<String, dynamic> src) {
    return AggregateGroupKey(
      src["field"],
      unit: src["unit"] != null
          ? EnumAggregateGroupUnit.values.byName(src["unit"])
          : null,
      utcOffsetMinutes: src["utcOffsetMinutes"],
      weekStart: src["weekStart"],
      startMonth: src["startMonth"],
      alias: src["alias"],
    );
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "field": field,
      "unit": unit?.name,
      "utcOffsetMinutes": utcOffsetMinutes,
      "weekStart": weekStart,
      "startMonth": startMonth,
      "alias": alias,
    };
  }

  @override
  AggregateGroupKey clone() {
    return AggregateGroupKey.fromDict(toDict());
  }
}
