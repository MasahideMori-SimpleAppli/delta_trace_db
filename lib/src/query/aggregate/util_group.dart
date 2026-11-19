import 'dart:convert';

import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:delta_trace_db/src/query/aggregate/util_aggregate.dart';
import 'package:delta_trace_db/src/query/util_date_time.dart';
import 'package:delta_trace_db/src/query/util_field.dart';

/// (en) Utilities for grouping the items of aggregate queries.
/// The results are identical to the Python version.
///
/// (ja) aggregateクエリのアイテムのグループ化用ユーティリティです。
/// 結果はPython版と同一になります。
class UtilGroup {
  /// (en) Groups the items and calculates the aggregations for each group.
  /// If [groupBy] is empty, all items form one group, and the result is a
  /// list that contains the result of UtilAggregate.calculate only.
  /// Otherwise, the groups are in the order in which they first appear in
  /// [items], and each result map contains the group key values followed by
  /// the aggregation results.
  ///
  /// (ja) アイテムをグループ化し、グループごとに集計を計算します。
  /// [groupBy] が空の場合は全アイテムが1つのグループになり、結果は
  /// UtilAggregate.calculate の結果だけを含むリストです。
  /// それ以外の場合、グループは [items] に最初に現れた順で並び、
  /// 各結果のマップはグループキーの値と、それに続く集計結果を含みます。
  ///
  /// * [items] : The target items.
  /// * [groupBy] : The group key definitions.
  /// * [aggregations] : The aggregation definitions.
  ///
  /// Throws [ArgumentError] if a definition is invalid or a value cannot be
  /// converted.
  static List<Map<String, dynamic>> calculate(
    List<Map<String, dynamic>> items,
    List<AggregateGroupKey> groupBy,
    List<Aggregation> aggregations,
  ) {
    final Set<String> outputKeys = aggregations.map((e) => e.outputKey).toSet();
    for (final AggregateGroupKey g in groupBy) {
      _check(g);
      if (!outputKeys.add(g.outputKey)) {
        throw ArgumentError("Duplicate output key: ${g.outputKey}");
      }
    }
    if (groupBy.isEmpty) {
      return [UtilAggregate.calculate(items, aggregations)];
    }
    final Map<String, List<dynamic>> keys = {};
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final Map<String, dynamic> item in items) {
      final List<dynamic> values = [
        for (final AggregateGroupKey g in groupBy) _keyValue(item, g),
      ];
      final String k = jsonEncode(values);
      keys.putIfAbsent(k, () => values);
      groups.putIfAbsent(k, () => []).add(item);
    }
    return [
      for (final String k in groups.keys)
        {
          for (var i = 0; i < groupBy.length; i++)
            groupBy[i].outputKey: UtilCopy.jsonableDeepCopy(keys[k]![i]),
          ...UtilAggregate.calculate(groups[k]!, aggregations),
        },
    ];
  }

  /// (en) Checks the parameters of a group key.
  ///
  /// (ja) グループキーのパラメータを検査します。
  ///
  /// * [g] : The group key.
  ///
  /// Throws [ArgumentError] if a parameter is invalid.
  static void _check(AggregateGroupKey g) {
    final int? offset = g.utcOffsetMinutes;
    if (g.unit == null && offset != null) {
      throw ArgumentError("utcOffsetMinutes requires unit (${g.field}).");
    }
    if (offset != null && (offset <= -1440 || offset >= 1440)) {
      throw ArgumentError(
        "utcOffsetMinutes must be greater than -1440 and less than 1440.",
      );
    }
    if (g.weekStart != null) {
      if (g.unit != EnumAggregateGroupUnit.week) {
        throw ArgumentError("weekStart can be used only with week.");
      }
      if (g.weekStart! < 1 || g.weekStart! > 7) {
        throw ArgumentError("weekStart must be 1-7.");
      }
    }
    if (g.startMonth != null) {
      if (g.unit != EnumAggregateGroupUnit.quarter &&
          g.unit != EnumAggregateGroupUnit.year) {
        throw ArgumentError(
          "startMonth can be used only with quarter or year.",
        );
      }
      if (g.startMonth! < 1 || g.startMonth! > 12) {
        throw ArgumentError("startMonth must be 1-12.");
      }
    }
  }

  /// (en) Returns the key value of an item for a group key.
  ///
  /// (ja) グループキーに対するアイテムのキーの値を返します。
  ///
  /// * [item] : The item.
  /// * [g] : The group key.
  ///
  /// Throws [ArgumentError] if the value cannot be read as a date-time.
  static dynamic _keyValue(Map<String, dynamic> item, AggregateGroupKey g) {
    final dynamic v = UtilField.getNestedFieldValue(item, g.field);
    if (g.unit == null || v == null) return v;
    final int offset = g.utcOffsetMinutes ?? 0;
    final NaiveOrUtc? d = v is String ? UtilDateTime.tryParse(v) : null;
    if (d == null) {
      throw ArgumentError(
        "Cannot read the value of field '${g.field}' as a date-time.",
      );
    }
    // UTC の DateTime に、区切りに使うタイムゾーンでの日時を入れる。
    final DateTime t = UtilDateTime.toUtc(
      d,
      offset,
    ).add(Duration(minutes: offset));
    final int startMonth = g.startMonth ?? 1;
    final int i = (t.month - startMonth + 12) % 12;
    switch (g.unit!) {
      case EnumAggregateGroupUnit.day:
        return _date(t);
      case EnumAggregateGroupUnit.week:
        final int diff = (t.weekday - (g.weekStart ?? 1) + 7) % 7;
        return _date(DateTime.utc(t.year, t.month, t.day - diff));
      case EnumAggregateGroupUnit.month:
        return _month(t.year, t.month);
      case EnumAggregateGroupUnit.quarter:
        final int start = t.month - i % 3;
        return "${_month(t.year, start)}/${_month(t.year, start + 2)}";
      case EnumAggregateGroupUnit.year:
        final int start = t.month - i;
        return "${_month(t.year, start)}/${_month(t.year, start + 11)}";
    }
  }

  /// (en) Returns the date as "YYYY-MM-DD".
  ///
  /// (ja) 日付を "YYYY-MM-DD" の形式で返します。
  ///
  /// * [t] : The date-time.
  static String _date(DateTime t) =>
      "${_month(t.year, t.month)}-${t.day.toString().padLeft(2, '0')}";

  /// (en) Returns the month as "YYYY-MM". [month] may be out of 1-12,
  /// in which case the year is carried over (e.g. year 2026, month 13 is
  /// "2027-01").
  ///
  /// (ja) 月を "YYYY-MM" の形式で返します。[month] は1-12の範囲外でもよく、
  /// その場合は年に繰り上げ・繰り下げします（例：2026年13月は "2027-01"）。
  ///
  /// * [year] : The year.
  /// * [month] : The month.
  static String _month(int year, int month) {
    final int total = year * 12 + month - 1;
    final String y = (total ~/ 12).toString().padLeft(4, '0');
    final String m = (total % 12 + 1).toString().padLeft(2, '0');
    return "$y-$m";
  }
}
