import '../../delta_trace_db.dart';

/// (en) The result class for a transactional query.
///
/// (ja) トランザクションクエリの結果クラスです。
class TransactionQueryResult<T> extends QueryExecutionResult {
  static const String className = "TransactionQueryResult";
  static const String version = "1";
  List<QueryResult> results;
  String? errorMessage;

  /// * [isNoErrors] : A flag indicating whether the operation was successful.
  /// * [results] : The QueryResults for each execution are stored in the same
  /// order as they were specified in the transaction query.
  /// * [errorMessage] : A message that is added only if an error occurs.
  TransactionQueryResult({
    required super.isNoErrors,
    required this.results,
    this.errorMessage,
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory TransactionQueryResult.fromDict(Map<String, dynamic> src) {
    List<QueryResult> qR = [];
    for (Map<String, dynamic> i in src["results"]) {
      qR.add(QueryResult.fromDict(i));
    }
    return TransactionQueryResult<T>(
      isNoErrors: src["isNoErrors"],
      results: qR,
      errorMessage: src["errorMessage"],
    );
  }

  @override
  TransactionQueryResult<T> clone() {
    return TransactionQueryResult<T>.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    List<Map<String, dynamic>> qR = [];
    for (QueryResult i in results) {
      qR.add(i.toDict());
    }
    return {
      "className": className,
      "version": version,
      "isNoErrors": isNoErrors,
      "results": (UtilCopy.jsonableDeepCopy(qR) as List)
          .cast<Map<String, dynamic>>(),
      "errorMessage": errorMessage,
    };
  }
}
