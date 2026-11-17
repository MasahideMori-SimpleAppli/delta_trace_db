import 'dart:convert';

import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:delta_trace_db/src/query/util_field.dart';

/// (en) Utilities for the joins of aggregate queries.
/// The results are identical to the Python version.
///
/// (ja) aggregateクエリの結合用ユーティリティです。
/// 結果はPython版と同一になります。
class UtilJoin {
  /// (en) Returns new maps in which the joined items are attached to each
  /// item under their aliases. The joins are applied in order, so a later
  /// join can use the fields of an earlier join as its localKey.
  /// The items themselves are not changed.
  ///
  /// (ja) 各アイテムに、結合したアイテムをエイリアスの名前で付けた新しいマップを
  /// 返します。結合は順番に適用されるため、後の結合の localKey には
  /// 前の結合のフィールドを使えます。元のアイテムは変更しません。
  ///
  /// * [items] : The items of the target collection.
  /// * [joins] : The join definitions.
  /// * [sources] : The items of each joined collection, keyed by the
  /// collection name. A collection that does not exist must not be included.
  ///
  /// Throws [ArgumentError] if a definition is invalid, a joined collection
  /// does not exist, or an item does not match exactly one joined item.
  static List<Map<String, dynamic>> join(
    List<Map<String, dynamic>> items,
    List<AggregateJoin> joins,
    Map<String, List<Map<String, dynamic>>> sources,
  ) {
    final Set<String> aliases = {};
    for (final AggregateJoin j in joins) {
      if (j.alias.isEmpty || j.alias.contains('.')) {
        throw ArgumentError("Invalid join alias: '${j.alias}'");
      }
      if (!aliases.add(j.alias)) {
        throw ArgumentError("Duplicate join alias: '${j.alias}'");
      }
    }
    List<Map<String, dynamic>> rows = items;
    for (final AggregateJoin j in joins) {
      final List<Map<String, dynamic>>? source = sources[j.collection];
      if (source == null) {
        throw ArgumentError(
          "The joined collection does not exist: '${j.collection}'",
        );
      }
      final Map<String, Map<String, dynamic>> index = {};
      final Set<String> duplicates = {};
      for (final Map<String, dynamic> s in source) {
        final dynamic v = UtilField.getNestedFieldValue(s, j.foreignKey);
        if (v == null) continue;
        final String k = jsonEncode(v);
        if (index.containsKey(k)) {
          duplicates.add(k);
        } else {
          index[k] = s;
        }
      }
      final List<Map<String, dynamic>> next = [];
      for (final Map<String, dynamic> r in rows) {
        if (r.containsKey(j.alias)) {
          throw ArgumentError(
            "The join alias '${j.alias}' is the same as a field of the item.",
          );
        }
        final dynamic v = UtilField.getNestedFieldValue(r, j.localKey);
        if (v == null) {
          throw ArgumentError(
            "The value of '${j.localKey}' is null (join alias: '${j.alias}').",
          );
        }
        final String k = jsonEncode(v);
        if (duplicates.contains(k)) {
          throw ArgumentError(
            "More than one item in '${j.collection}' has the same "
            "${j.foreignKey} as '${j.localKey}' (join alias: '${j.alias}').",
          );
        }
        final Map<String, dynamic>? matched = index[k];
        if (matched == null) {
          throw ArgumentError(
            "No item in '${j.collection}' has the same ${j.foreignKey} "
            "as '${j.localKey}' (join alias: '${j.alias}').",
          );
        }
        next.add({...r, j.alias: matched});
      }
      rows = next;
    }
    return rows;
  }
}
