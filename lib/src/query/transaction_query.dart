import 'package:file_state_manager/file_state_manager.dart';
import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) This is a query class that supports transaction processing.
/// It internally stores normal query classes as an array,
/// and the targets are processed as transactions.
///
/// (ja) トランザクション処理に対応したクエリクラスです。
/// 内部に通常のクエリクラスを配列で保持しており、対象はトランザクション処理されます。
class TransactionQuery extends CloneableFile {
  static const String className = "TransactionQuery";
  static const String version = "1";

  List<Query> queries;

  /// * [queries] : The transaction targets.
  TransactionQuery({required this.queries});

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory TransactionQuery.fromDict(Map<String, dynamic> src) {
    List<Query> q = [];
    for (Map<String, dynamic> i in src["queries"]) {
      q.add(Query.fromDict(i));
    }
    return TransactionQuery(queries: q);
  }

  @override
  Map<String, dynamic> toDict() {
    List<Map<String, dynamic>> q = [];
    for (Query i in queries) {
      q.add(i.toDict());
    }
    return {"className": className, "version": version, "queries": q};
  }

  @override
  TransactionQuery clone() {
    return TransactionQuery.fromDict(toDict());
  }
}
