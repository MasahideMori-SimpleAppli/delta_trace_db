import 'package:file_state_manager/file_state_manager.dart';

import '../../delta_trace_db.dart';

/// (ja) DBへのクエリ結果や付加情報を格納したクラスです。
class QueryResult<T> extends CloneableFile {
  static const String className = "QueryResult";
  static const String version = "1";
  bool isNoErrors;
  List<Map<String, dynamic>> result;
  int dbLength;
  int updateCount;
  int hitCount;
  String? errorMessage;

  /// * [isNoErrors] : 操作が成功したかどうかのフラグ。
  /// これはエラーが発生していないかどうかを表すため、検索や更新数が0でもtrueになります。
  /// * [result] : 検索結果、更新結果、削除されたオブジェクトなど。
  /// * [dbLength] : DB内のデータの総数。
  /// * [updateCount] : 更新、または削除されたデータの総数。
  /// * [hitCount] : 検索対象になったデータの総数。
  /// * [errorMessage] : エラー発生時のみ追加されるメッセージ。
  QueryResult({
    required this.isNoErrors,
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

  /// 検索結果を指定クラスの配列で取得します。
  /// * [fromDict] : クラスTがCloneableFileである場合、
  /// 辞書からオブジェクトを復元するためのfromDict相当の関数を渡します。
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
