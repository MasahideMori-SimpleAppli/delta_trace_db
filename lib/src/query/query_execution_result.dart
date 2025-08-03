import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';

///　(en) An abstract class for handling both QueryResult and
/// TransactionQueryResult collectively.
///
/// (ja) QueryResult と TransactionQueryResult の両方を
/// まとめて処理するための抽象クラス。
abstract class QueryExecutionResult extends CloneableFile {
  bool isNoErrors;

  /// * [isNoErrors] : A flag indicating whether the operation was successful.
  /// This also changes depending on the value of the optional argument
  /// mustAffectAtLeastOne when creating a query.
  /// When mustAffectAtLeastOne is true,
  /// if the number of operation targets is 0,
  /// it will be treated as an error and the value will be false.
  /// When false, the value will be true even if the number of updates is 0.
  /// In other cases, if an exception occurs internally,
  /// it will be treated as an error.
  QueryExecutionResult({required this.isNoErrors});

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  static QueryExecutionResult fromDict(Map<String, dynamic> src) {
    final String className = src["className"];
    if (className == "QueryResult") {
      return QueryResult.fromDict(src);
    } else if (className == "TransactionQueryResult") {
      return TransactionQueryResult.fromDict(src);
    } else {
      throw ArgumentError(
        "QueryExecutionResult: The object cannot be converted.",
      );
    }
  }
}
