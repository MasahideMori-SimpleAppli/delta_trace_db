/// (en) An enum that defines the node type.
///
/// (ja) ノードタイプを定義したEnumです。
enum EnumNodeType {
  // 論理演算ノード (構造的に条件を組み立てる)
  and_,
  or_,
  not_,

  // 比較/条件ノード (フィールド値に対して条件を設定)
  equals_,
  notEquals_,
  greaterThan_,
  lessThan_,
  greaterThanOrEqual_,
  lessThanOrEqual_,
  regex_,
  contains_,
  in_,
  notIn_,
  startsWith_,
  endsWith_,
}
