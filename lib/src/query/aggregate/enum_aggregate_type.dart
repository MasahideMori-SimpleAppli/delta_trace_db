/// (en) The type of aggregation used in an aggregate query.
///
/// (ja) aggregateクエリで使用する集計の種類です。
enum EnumAggregateType {
  /// (en) The number of items. If a field is specified,
  /// the number of items whose field value is not null.
  ///
  /// (ja) 件数です。フィールドを指定した場合は、その値がnullでない件数です。
  count_,

  /// (en) The sum of the field values.
  ///
  /// (ja) フィールドの値の合計です。
  sum_,

  /// (en) The minimum of the field values.
  ///
  /// (ja) フィールドの値の最小値です。
  min_,

  /// (en) The maximum of the field values.
  ///
  /// (ja) フィールドの値の最大値です。
  max_,

  /// (en) The arithmetic mean of the field values.
  ///
  /// (ja) フィールドの値の算術平均です。
  mean_,
}
