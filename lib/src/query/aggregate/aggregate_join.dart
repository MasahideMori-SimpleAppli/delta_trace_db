import 'package:file_state_manager/file_state_manager.dart';

/// (en) A definition of a join in an aggregate query.
/// For each item of the target collection, the item of [collection] whose
/// [foreignKey] value equals the [localKey] value is attached under [alias],
/// so its fields can be referenced as "alias.field" in the query node,
/// the group keys and the aggregations.
/// Exactly one item must match. If no item matches, more than one item
/// matches, or the [localKey] value is null, the query fails.
/// Values are compared by their JSON representation,
/// so 1 and "1" do not match.
///
/// (ja) aggregateクエリにおける結合の定義です。
/// 対象コレクションの各アイテムに、[foreignKey] の値が [localKey] の値と等しい
/// [collection] のアイテムを [alias] の名前で付けます。
/// これにより、検索ノード・グループキー・集計で "alias.フィールド" として
/// 参照できます。
/// 一致するアイテムは必ず1件である必要があります。一致するアイテムがない場合、
/// 複数ある場合、または [localKey] の値が null の場合はクエリが失敗します。
/// 値は JSON での表現で比較されるため、1 と "1" は一致しません。
class AggregateJoin extends CloneableFile {
  static const String className = "AggregateJoin";
  static const String version = "1";

  final String collection;
  final String localKey;
  final String foreignKey;
  final String alias;

  /// (en) A definition of a join in an aggregate query.
  ///
  /// (ja) aggregateクエリにおける結合の定義です。
  ///
  /// * [collection] : The name of the collection to join.
  /// * [localKey] : The field of the target item whose value is used for
  /// the join. Nested fields and fields of earlier joins can be specified
  /// with dot notation.
  /// * [foreignKey] : The field of the joined item that is compared with the
  /// [localKey] value. Nested fields can be specified with dot notation.
  /// * [alias] : The name under which the joined item is attached.
  /// It must not be empty, contain a dot, or be the same as a field of the
  /// target item or another alias.
  AggregateJoin({
    required this.collection,
    required this.localKey,
    required this.foreignKey,
    required this.alias,
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory AggregateJoin.fromDict(Map<String, dynamic> src) {
    return AggregateJoin(
      collection: src["collection"],
      localKey: src["localKey"],
      foreignKey: src["foreignKey"],
      alias: src["alias"],
    );
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "collection": collection,
      "localKey": localKey,
      "foreignKey": foreignKey,
      "alias": alias,
    };
  }

  @override
  AggregateJoin clone() {
    return AggregateJoin.fromDict(toDict());
  }
}
