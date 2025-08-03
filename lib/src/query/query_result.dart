import '../../delta_trace_db.dart';

/// (en) This class stores the query results and additional information from
/// the database.
///
/// (ja) DBへのクエリ結果や付加情報を格納したクラスです。
class QueryResult<T> extends QueryExecutionResult {
  static const String className = "QueryResult";
  static const String version = "2";
  List<Map<String, dynamic>> result;
  int dbLength;
  int updateCount;
  int hitCount;
  String? errorMessage;

  /// * [isNoErrors] : A flag indicating whether the operation was successful.
  /// This also changes depending on the value of the optional argument
  /// mustAffectAtLeastOne when creating a query.
  /// When mustAffectAtLeastOne is true,
  /// if the number of operation targets is 0,
  /// it will be treated as an error and the value will be false.
  /// When false, the value will be true even if the number of updates is 0.
  /// In other cases, if an exception occurs internally,
  /// it will be treated as an error.
  /// * [result] : Search results, update results, deleted objects, etc.
  /// * [dbLength] : The total number of records in the DB.
  /// * [updateCount] : The total number of records add, updated or deleted.
  /// * [hitCount] : The total number of records searched.
  /// * [errorMessage] : A message that is added only if an error occurs.
  QueryResult({
    required super.isNoErrors,
    required this.result,
    required this.dbLength,
    required this.updateCount,
    required this.hitCount,
    this.errorMessage,
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory QueryResult.fromDict(Map<String, dynamic> src) {
    return QueryResult<T>(
      isNoErrors: src["isNoErrors"],
      result: (src["result"] as List).cast<Map<String, dynamic>>(),
      dbLength: src["dbLength"],
      updateCount: src["updateCount"],
      hitCount: src["hitCount"],
      errorMessage: src["errorMessage"],
    );
  }

  /// (en) The search results will be retrieved as an array of
  /// the specified class.
  ///
  /// (ja) 検索結果を指定クラスの配列で取得します。
  ///
  /// * [fromDict] : If class T is CloneableFile,
  /// Pass a function equivalent to fromDict to restore the object from
  /// a dictionary.
  List<T> convert(T Function(Map<String, dynamic>) fromDict) {
    List<T> r = [];
    for (Map<String, dynamic> i in result) {
      r.add(fromDict(i));
    }
    return r;
  }

  @override
  QueryResult<T> clone() {
    return QueryResult<T>.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "isNoErrors": isNoErrors,
      "result": (UtilCopy.jsonableDeepCopy(result) as List)
          .cast<Map<String, dynamic>>(),
      "dbLength": dbLength,
      "updateCount": updateCount,
      "hitCount": hitCount,
      "errorMessage": errorMessage,
    };
  }
}
