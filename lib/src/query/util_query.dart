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
        throw ArgumentError("Unsupported query class: ${src["className"]}");
      }
    } catch (e) {
      throw ArgumentError("Unsupported object");
    }
  }
}
