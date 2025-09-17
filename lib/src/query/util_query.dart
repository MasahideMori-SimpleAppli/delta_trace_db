import '../../delta_trace_db.dart';

/// (en) Utilities for query processing.
///
/// (ja) クエリ処理用のユーティリティです。
class UtilQuery {
  /// (en) Restores a Query or TransactionQuery class from a JSON Map.
  ///
  /// (ja) JSONのMapから、QueryまたはTransactionQueryクラスを復元します。
  ///
  /// * [src] : The map of Query class or TransactionQuery class.
  ///
  /// Throws : ArgumentError. If you pass an incorrect class.
  static dynamic convertFromJson(Map<String, dynamic> src) {
    try {
      if (src["className"] == "Query") {
        return Query.fromDict(src);
      } else if (src["className"] == "TransactionQuery") {
        return TransactionQuery.fromDict(src);
      } else {
        throw ArgumentError("Unsupported query class");
      }
    } catch (e) {
      throw ArgumentError("Unsupported object");
    }
  }

  /// (en) Checks the collection operation permissions for the target query and
  /// returns true if there are no problems.
  ///
  /// (ja) 対象クエリに関するコレクションの操作権限をチェックし、問題なければtrueを返します。
  ///
  /// * [q] : The query you want to look up.
  /// * [collectionPermissions] : The permissions of the user performing
  /// this operation.
  /// Use null on the frontend, if this is null then everything is allowed.
  static bool checkPermissions(
    Query q,
    Map<String, Permission>? collectionPermissions,
  ) {
    if (collectionPermissions == null) {
      return true;
    } else {
      if (!collectionPermissions.containsKey(q.target)) {
        return false;
      } else {
        // allowsのチェック。
        final Permission p = collectionPermissions[q.target]!;
        if (p.allows.contains(q.type)) {
          return true;
        }
        return false;
      }
    }
  }
}
