/// (en) The comparison type definition for the query node.
///
/// (ja) クエリノードの比較タイプの定義です。
enum EnumValueType {
  auto_, // default
  datetime_,
  int_,
  floatStrict_,
  floatEpsilon12_, // Tolerance 1e-12
  boolean_,
  string_,
}
