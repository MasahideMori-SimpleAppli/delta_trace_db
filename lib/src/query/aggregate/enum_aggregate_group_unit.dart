/// (en) The period used to group date-time values in an aggregate query.
/// The label of each group is a string that sorts in time order.
///
/// (ja) aggregateクエリで日時の値をグループ化する期間です。
/// 各グループのラベルは、時系列順に並ぶ文字列です。
enum EnumAggregateGroupUnit {
  /// (en) One day. The label is the date (e.g. "2026-10-05").
  ///
  /// (ja) 1日です。ラベルはその日付です（例："2026-10-05"）。
  day,

  /// (en) One week. The label is the first day of the week
  /// (e.g. "2026-10-05"). The first day is set by weekStart.
  ///
  /// (ja) 1週間です。ラベルは週の初日の日付です（例："2026-10-05"）。
  /// 週の始まりの曜日は weekStart で指定します。
  week,

  /// (en) One month. The label is the month (e.g. "2026-10").
  ///
  /// (ja) 1か月です。ラベルはその月です（例："2026-10"）。
  month,

  /// (en) Three months. The label is the first and last months
  /// (e.g. "2026-04/2026-06"). The first quarter starts in startMonth.
  ///
  /// (ja) 3か月です。ラベルは最初と最後の月です（例："2026-04/2026-06"）。
  /// 最初の四半期は startMonth から始まります。
  quarter,

  /// (en) One year. The label is the first and last months
  /// (e.g. "2026-04/2027-03"). The year starts in startMonth.
  ///
  /// (ja) 1年です。ラベルは最初と最後の月です（例："2026-04/2027-03"）。
  /// 年は startMonth から始まります。
  year,
}
