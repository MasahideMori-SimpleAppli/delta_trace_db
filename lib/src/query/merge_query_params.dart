import 'package:file_state_manager/file_state_manager.dart';

/// (en) This class defines special parameters for merge queries.
///
/// (ja) mergeクエリ用の専用パラメータを定義したクラスです。
class MergeQueryParams extends CloneableFile {
  static const String className = "MergeQueryParams";
  static const String version = "1";
  final String base;
  final List<String> source;
  final String relationKey;
  final List<String>? sourceKeys;
  final String output;
  final Map<String, dynamic> dslTmp;
  final String? serialBase;
  final String? serialKey;

  /// * [base]: The name of the collection used as the base when merging.
  /// * [source]: An array of names of the source collections to be merged.
  /// Each element corresponds to the array index on `dslTmp`.
  /// * [relationKey]: The key name defined on items in the base collection
  /// that is used to establish the relation.
  /// In each source collection, the first object that has the same key name
  /// and value as an item in the base collection will be merged.
  /// If a different key name is used on the source collection side,
  /// set the `sourceKeys` parameter.
  /// * [sourceKeys]: Usually `null`. This is used when the key names for the
  /// relation differ between the base collection and the source collections.
  /// Specify, for each source collection, the name of the key on the source
  /// side whose value corresponds to `relationKey`.
  /// * [output]: The name of the output collection.
  /// * [dslTmp]: Structural information of the merged items described in DSL.
  /// * [serialBase]: When set, the serial number currently managed within the
  /// specified collection will be inherited.
  /// * [serialKey]: When set, the value of the specified key in `dslTmp` is
  /// treated as a serial key, and a serial number starting from 0 is assigned
  /// when adding items. This option is ignored if `serialBase` is set.
  ///
  /// ---
  ///
  /// (en)
  /// Relation semantics:
  /// - For each base item, at most one item is selected from each source collection.
  /// - The source items are aligned by index with the `source` list.
  /// - In DSL, source items can be referenced as `0.xxx`, `1.xxx`, etc.
  /// - If no matching source item is found, the source is treated as empty.
  ///
  /// (ja)
  /// リレーション仕様:
  /// - 各ベースアイテムに対して、各ソースコレクションから最大 1 つのアイテムが選択されます。
  /// - ソースアイテムは、`source` リストのインデックスで整列されます。
  /// - DSL では、ソースアイテムは `0.xxx`、`1.xxx` のように参照できます。
  /// - 一致するソースアイテムが見つからない場合、ソースは空として扱われます。
  ///
  /// ---
  MergeQueryParams({
    required this.base,
    required this.source,
    required this.relationKey,
    required this.sourceKeys,
    required this.output,
    required this.dslTmp,
    this.serialBase,
    this.serialKey,
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory MergeQueryParams.fromDict(Map<String, dynamic> src) {
    return MergeQueryParams(
      base: src["base"],
      source: src["source"],
      relationKey: src["relationKey"],
      sourceKeys: src["sourceKeys"],
      output: src["output"],
      dslTmp: src["dslTmp"],
      serialBase: src["serialBase"],
      serialKey: src["serialKey"],
    );
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "base": base,
      "source": source,
      "relationKey": relationKey,
      "sourceKeys": sourceKeys,
      "dslTmp": dslTmp,
      "output": output,
      "serialBase": serialBase,
      "serialKey": serialKey,
    };
  }

  @override
  MergeQueryParams clone() {
    return MergeQueryParams.fromDict(toDict());
  }
}
