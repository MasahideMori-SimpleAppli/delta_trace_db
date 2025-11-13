import 'package:file_state_manager/file_state_manager.dart';

import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) A builder class for easily constructing queries.
/// In addition to constructors for creating each query,
/// there are methods for dynamically changing the paging parameters.
///
/// (ja) クエリを簡単に組み立てるためのビルダークラスです。
/// 各クエリを作成するためのコンストラクタの他に、
/// ページング用のパラメータを動的に変更するためのメソッドがあります。
///
/// Paging setting methods
/// - [setOffset]
/// - [setStartAfter]
/// - [setEndBefore]
/// - [setLimit]
class QueryBuilder {
  String target;
  EnumQueryType type;
  List<CloneableFile>? addData;
  Map<String, dynamic>? overrideData;
  Map<String, dynamic>? template;
  QueryNode? queryNode;
  AbstractSort? sortObj;
  int? offset;
  Map<String, dynamic>? startAfter;
  Map<String, dynamic>? endBefore;
  String? renameBefore;
  String? renameAfter;
  int? limit;
  bool returnData = false;
  bool mustAffectAtLeastOne = true;
  String? serialKey;
  bool resetSerial = false;
  Cause? cause;

  /// (en) Adds an item to the specified collection.
  /// If the specified collection does not already exist,
  /// it will be created automatically.
  ///
  /// (ja) 指定されたコレクションに要素を追加します。
  /// 指定されたコレクションがまだ存在しない場合はコレクションが自動で作成されます。
  ///
  /// * [target] : The collection name in DB.
  /// * [addData] : Data specified when performing an add operation.
  /// Typically, this is assigned the list that results from calling toDict on
  /// a subclass of ClonableFile.
  /// * [returnData] : If true, return the changed objs.
  /// If serialKey is set, the object will be returned with
  /// the serial number added.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [serialKey] : If not null, the add query will assign a unique serial
  /// number (integer value) to the specified key.
  /// This value is unique per collection.
  /// Note that only variables directly under the class can be specified as
  /// keys, not nested fields.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.add({
    required this.target,
    required List<CloneableFile> this.addData,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.serialKey,
    this.cause,
  }) : type = EnumQueryType.add;

  /// (en) Overwrites the parameters of all objects in the specified collection
  /// that match the conditions.
  /// Parameters not specified for overwriting remain unchanged.
  ///
  /// (ja) 指定されたコレクションのうち、条件にマッチする全てのオブジェクトのパラメータを
  /// 上書きします。上書き対象に指定していないパラメータは変化しません。
  ///
  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [overrideData] : This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
  /// The parameters directly below will be updated.
  /// For example, if the original data is {"a": 0, "b": {"c": 1}},
  /// and you update it by data of {"b": {"d": 2}},
  /// the result will be {"a": 0, "b": {"d": 2}}.
  /// * [returnData] : If true, return the changed objs.
  /// * [sortObj] : An object for sorting the return values.
  ///   - SingleSort or MultiSort can be used.
  ///   - Optional. If omitted, results will be returned in the order
  ///   they were added to the database.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.update({
    required this.target,
    required QueryNode this.queryNode,
    required Map<String, dynamic> this.overrideData,
    this.returnData = false,
    this.sortObj,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.update;

  /// (en) Overwrites the parameters of one object in the specified collection
  /// that matches the conditions. Parameters not specified for overwriting
  /// remain unchanged.
  ///
  /// (ja) 指定されたコレクションのうち、条件にマッチする１つのオブジェクトのパラメータを
  /// 上書きします。上書き対象に指定していないパラメータは変化しません。
  ///
  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [overrideData] : This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
  /// The parameters directly below will be updated.
  /// For example, if the original data is {"a": 0, "b": {"c": 1}},
  /// and you update it by data of {"b": {"d": 2}},
  /// the result will be {"a": 0, "b": {"d": 2}}.
  /// * [returnData] : If true, return the changed objs.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.updateOne({
    required this.target,
    required QueryNode this.queryNode,
    required Map<String, dynamic> this.overrideData,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.updateOne;

  /// (en) Deletes all objects in the specified collection that match
  /// the specified criteria.
  ///
  /// (ja) 指定されたコレクションのうち、条件にマッチするオブジェクトを全て削除します。
  ///
  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [returnData] : If true, return the changed objs.
  /// * [sortObj] : An object for sorting the return values.
  ///   - SingleSort or MultiSort can be used.
  ///   - Optional. If omitted, results will be returned in the order
  ///   they were added to the database.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.delete({
    required this.target,
    required QueryNode this.queryNode,
    this.returnData = false,
    this.sortObj,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.delete;

  /// (en) Deletes only one object that matches the specified criteria from
  /// the specified collection.
  ///
  /// (ja) 指定されたコレクションのうち、条件にマッチするオブジェクトを１件だけ削除します。
  ///
  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [returnData] : If true, return the changed objs.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.deleteOne({
    required this.target,
    required QueryNode this.queryNode,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.deleteOne;

  /// (en) Gets objects from the specified collection that match
  /// the specified criteria.
  ///
  /// (ja) 指定されたコレクションから、条件にマッチするオブジェクトを取得します。
  ///
  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [sortObj] : An object for sorting the return values.
  ///   - SingleSort or MultiSort can be used.
  ///   - Optional. If omitted, results will be returned in the order
  ///   they were added to the database.
  /// * [offset] : An offset for front-end paging support.
  /// If specified, data after the specified offset will be retrieved.
  /// * [startAfter] : If you pass in a serialized version of a search result
  /// object, the search will return results from objects after that object,
  /// and if an offset is specified, it will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  /// * [endBefore] : If you pass in a serialized version of a search result
  /// object, the search will return results from the object before that one,
  /// and any offset or startAfter specified will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  /// * [limit] : The maximum number of search results.
  ///   - With offset/startAfter: returns up to [limit] items after the
  ///   specified position.
  ///   - With endBefore: returns up to [limit] items before the specified
  ///   position.
  ///   - If no offset/startAfter/endBefore is specified, the first [limit]
  ///   items in addition order are returned.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.search({
    required this.target,
    required QueryNode this.queryNode,
    this.sortObj,
    this.offset,
    this.startAfter,
    this.endBefore,
    this.limit,
    this.cause,
  }) : type = EnumQueryType.search;

  /// (en) Gets objects from the specified collection that match
  /// the specified criteria.
  /// It is faster than a "search query" when searching for a single item
  /// because the search stops once a hit is found.
  ///
  /// (ja) 指定されたコレクションから、条件にマッチするオブジェクトを取得します。
  /// 1件のヒットがあった時点で探索を打ち切るため、
  /// 単一のアイテムを検索する場合はsearchよりも高速に動作します。
  ///
  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.searchOne({
    required this.target,
    required QueryNode this.queryNode,
    this.cause,
  }) : type = EnumQueryType.searchOne;

  /// (en) Gets all items in the specified collection.
  /// If a limit(limit, offset, startAfter, endBefore, limit) is set,
  /// items from the specified location and quantity will be retrieved from
  /// all items.
  ///
  /// (ja) 指定されたコレクションの全てのアイテムを取得します。
  /// 制限(limit, offset, startAfter, endBefore, limit)をかけた場合は、
  /// 全てのアイテムから指定の位置と量のアイテムを取得します。
  ///
  /// * [target] : The collection name in DB.
  /// * [sortObj] : An object for sorting the return values.
  ///   - SingleSort or MultiSort can be used.
  ///   - Optional. If omitted, results will be returned in the order
  ///   they were added to the database.
  /// * [offset] : An offset for front-end paging support.
  /// If specified, data after the specified offset will be retrieved.
  /// * [startAfter] : If you pass in a serialized version of a search result
  /// object, the search will return results from objects after that object,
  /// and if an offset is specified, it will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  /// * [endBefore] : If you pass in a serialized version of a search result
  /// object, the search will return results from the object before that one,
  /// and any offset or startAfter specified will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  /// * [limit] : The maximum number of search results.
  ///   - With offset/startAfter: returns up to [limit] items after the
  ///   specified position.
  ///   - With endBefore: returns up to [limit] items before the specified
  ///   position.
  ///   - If no offset/startAfter/endBefore is specified, the first [limit]
  ///   items in addition order are returned.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.getAll({
    required this.target,
    this.sortObj,
    this.offset,
    this.startAfter,
    this.endBefore,
    this.limit,
    this.cause,
  }) : type = EnumQueryType.getAll;

  /// (en) Formats the contents of the specified collection to match the
  /// specified template.
  /// Fields not present in the template will be removed,
  /// and fields that are only present in the template will be added
  /// with the template's value as their initial value.
  ///
  /// (ja) 指定されたコレクションの内容を、指定したテンプレートに一致するように整形します。
  /// テンプレートに存在しないフィールドは削除され、テンプレートにのみ存在するフィールドは、
  /// テンプレートの値を初期値として追加されます。
  ///
  /// * [target] : The collection name in DB.
  /// * [template] : Specify this when changing the structure of the DB class.
  /// Fields that do not exist in the existing structure but exist in the
  /// template will be added with the template value as the initial value.
  /// Fields that do not exist in the template will be deleted.
  /// Usually, you pass a dictionary created by converting CloneableFile to
  /// Map (call toDict).
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.conformToTemplate({
    required this.target,
    required Map<String, dynamic> this.template,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.conformToTemplate;

  /// (en) Renames a specific field in the specified collection.
  ///
  /// (ja) 指定されたコレクションの特定のフィールドの名前を変更します。
  ///
  /// * [target] : The collection name in DB.
  /// * [renameBefore] : The old variable name when querying for a rename.
  /// * [renameAfter] : The new name of the variable when querying for a rename.
  /// * [returnData] : If true, return the changed objs.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.renameField({
    required this.target,
    required String this.renameBefore,
    required String this.renameAfter,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.renameField;

  /// (en) Gets the number of elements in the specified collection.
  ///
  /// (ja) 指定されたコレクションの要素数を取得します。
  ///
  /// * [target] : The collection name in DB.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.count({required this.target, this.cause})
    : type = EnumQueryType.count;

  /// (en) This query empties the contents of the specified collection.
  ///
  /// (ja) このクエリは指定したコレクションの内容を空にします。
  ///
  /// * [target] : The collection name in DB.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [resetSerial] : If true, resets the managed serial number to 0 on
  /// a clear or clearAdd query.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.clear({
    required this.target,
    this.mustAffectAtLeastOne = true,
    this.resetSerial = false,
    this.cause,
  }) : type = EnumQueryType.clear;

  /// (en) Clears the specified collection and then add data.
  ///
  /// (ja) 指定されたコレクションをclearした後、dataをAddします。
  ///
  /// * [target] : The collection name in DB.
  /// * [addData] : Data specified when performing an add operation.
  /// Typically, this is assigned the list that results from calling toDict on
  /// a subclass of ClonableFile.
  /// * [returnData] : If true, return the changed objs.
  /// If serialKey is set, the object will be returned with
  /// the serial number added.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [serialKey] : If not null, the add query will assign a unique serial
  /// number (integer value) to the specified key.
  /// This value is unique per collection.
  /// Note that only variables directly under the class can be specified as
  /// keys, not nested fields.
  /// * [resetSerial] : If true, resets the managed serial number to 0 on
  /// a clear or clearAdd query.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.clearAdd({
    required this.target,
    required List<CloneableFile> this.addData,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.serialKey,
    this.resetSerial = false,
    this.cause,
  }) : type = EnumQueryType.clearAdd;

  /// (en) Deletes the specified collection.
  /// This query is special because it deletes the collection itself.
  /// Therefore, it cannot be included as part of a transaction query.
  /// Additionally, any callbacks associated with the target collection will
  /// not be called when executed.
  /// This is a maintenance function for administrators who need to change
  /// the database structure.
  /// Typically, the database should be designed so that it never needs to be
  /// called.
  ///
  /// (ja) 指定されたコレクションを削除します。
  /// このクエリは特殊で、コレクションそのものが削除されるため
  /// トランザクションクエリの一部として含めることはできません。
  /// また、実行時には対象のコレクションに紐付いたコールバックも呼ばれません。
  /// これはDBの構造変更が必要な管理者のためのメンテナンス機能であり、
  /// 通常はこれを呼び出さないでも問題ない設計にしてください。
  ///
  /// * [target] : The collection name in DB.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  QueryBuilder.removeCollection({
    required this.target,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : type = EnumQueryType.removeCollection;

  /// (en) This method can be used if you want to change only the search position.
  ///
  /// (ja) 検索位置だけを変更したい場合に利用できるメソッドです。
  ///
  /// * [newOffset] : An offset for paging support in the front end.
  /// If specified, data from the offset onwards will be retrieved.
  QueryBuilder setOffset(int? newOffset) {
    offset = newOffset;
    return this;
  }

  /// (en) This method can be used if you want to change only the search position.
  ///
  /// (ja) 検索位置だけを変更したい場合に利用できるメソッドです。
  ///
  /// * [newStartAfter] : If you pass in a serialized version of a search result
  /// object, the search will return results from objects after that object,
  /// and if an offset is specified, it will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  QueryBuilder setStartAfter(Map<String, dynamic>? newStartAfter) {
    startAfter = newStartAfter;
    return this;
  }

  /// (en) This method can be used if you want to change only the search position.
  ///
  /// (ja) 検索位置だけを変更したい場合に利用できるメソッドです。
  ///
  /// * [newEndBefore] : If you pass in a serialized version of a search result
  /// object, the search will return results from the object before that one,
  /// and any offset or startAfter specified will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  QueryBuilder setEndBefore(Map<String, dynamic>? newEndBefore) {
    endBefore = newEndBefore;
    return this;
  }

  /// (en) This method can be used if you want to change only the limit.
  ///
  /// (ja) limitだけを変更したい場合に利用できるメソッドです。
  ///
  /// * [newLimit] : The maximum number of search results.
  ///   - With offset/startAfter: returns up to [limit] items after the
  ///   specified position.
  ///   - With endBefore: returns up to [limit] items before the specified
  ///   position.
  ///   - If no offset/startAfter/endBefore is specified, the first [limit]
  ///   items in addition order are returned.
  QueryBuilder setLimit(int? newLimit) {
    limit = newLimit;
    return this;
  }

  /// (en) Commit the content and convert it into a query object.
  ///
  /// (ja) 内容を確定してクエリーオブジェクトに変換します。
  Query build() {
    List<Map<String, dynamic>>? mData = [];
    if (addData != null) {
      for (CloneableFile i in addData!) {
        mData.add(i.toDict());
      }
    } else {
      mData = null;
    }
    return Query(
      target: target,
      type: type,
      addData: mData,
      overrideData: overrideData,
      template: template,
      queryNode: queryNode,
      sortObj: sortObj,
      offset: offset,
      startAfter: startAfter,
      endBefore: endBefore,
      renameBefore: renameBefore,
      renameAfter: renameAfter,
      limit: limit,
      returnData: returnData,
      mustAffectAtLeastOne: mustAffectAtLeastOne,
      serialKey: serialKey,
      resetSerial: resetSerial,
      cause: cause,
    );
  }
}
