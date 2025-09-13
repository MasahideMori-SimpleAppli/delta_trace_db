import '../../delta_trace_db.dart';

/// (en) This class stores the query results and additional information from
/// the database.
///
/// (ja) DBへのクエリ結果や付加情報を格納したクラスです。
class QueryResult<T> extends QueryExecutionResult {
  static const String className = "QueryResult";
  static const String version = "5";
  String target;
  EnumQueryType type;
  List<Map<String, dynamic>> result;
  int dbLength;
  int updateCount;
  int hitCount;
  String? errorMessage;

  /// * [isSuccess] : A flag indicating whether the operation was successful.
  /// This also changes depending on the value of the optional argument
  /// mustAffectAtLeastOne when creating a query.
  /// When mustAffectAtLeastOne is true,
  /// if the number of operation targets is 0,
  /// it will be treated as an error and the value will be false.
  /// When false, the value will be true even if the number of updates is 0.
  /// In other cases, if an exception occurs internally,
  /// it will be treated as an error.
  /// * [target] : The query target collection name in DB.
  /// This was introduced in version 5 of this class.
  /// If the server is running an earlier version,
  /// an empty string is substituted.
  /// * [type] : The query type for this result.
  /// The query type at the time of submission is entered as is.
  /// * [result] : The operation result data.
  ///   Always a list of serialized map objects (JSON).
  ///   Its meaning depends on [type]:
  ///   - For "search": The list contains matched objects.
  ///   - For "add": The list contains the added objects with serial keys.
  ///   - For "update": The list contains updated objects.
  ///   - For "delete": The list contains deleted objects.
  ///   Note: For add/update/delete, the list is only populated if the
  ///   query option [returnData] is set to true.
  /// * [dbLength] : DB side item length.
  /// This is The total number of records in the collection.
  /// * [updateCount] : The total number of records add, updated or deleted.
  /// * [hitCount] : The total number of records searched.
  /// * [errorMessage] : A message that is added only if an error occurs.
  QueryResult({
    required super.isSuccess,
    required this.target,
    required this.type,
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
      isSuccess: src["isSuccess"],
      target: src.containsKey("target") ? src["target"] : "",
      type: EnumQueryType.values.byName(src["type"]),
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
      "isSuccess": isSuccess,
      "target": target,
      "type": type.name,
      "result": (UtilCopy.jsonableDeepCopy(result) as List)
          .cast<Map<String, dynamic>>(),
      "dbLength": dbLength,
      "updateCount": updateCount,
      "hitCount": hitCount,
      "errorMessage": errorMessage,
    };
  }
}
