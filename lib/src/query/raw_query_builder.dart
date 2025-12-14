import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) A builder class for easily constructing queries.
/// This version differs from the normal QueryBuilder in that it passes a Map
/// directly without using a ClonableFile.
/// In addition to constructors for creating each query,
/// there are methods for dynamically changing the paging parameters.
///
/// (ja) クエリを簡単に組み立てるためのビルダークラスです。
/// このバージョンは通常のQueryBuilderと異なり、ClonableFileを使用せずにMapを直接渡します。
/// 各クエリを作成するためのコンストラクタの他に、
/// ページング用のパラメータを動的に変更するためのメソッドがあります。
///
/// Paging setting methods
/// - [setOffset]
/// - [setStartAfter]
/// - [setEndBefore]
/// - [setLimit]
class RawQueryBuilder extends QueryBuilder {
  List<Map<String, dynamic>>? rawAddData;

  /// (en) Adds an item to the specified collection.
  /// If the specified collection does not already exist,
  /// it will be created automatically.
  ///
  /// (ja) 指定されたコレクションに要素を追加します。
  /// 指定されたコレクションがまだ存在しない場合はコレクションが自動で作成されます。
  ///
  /// * [target] : The collection name in DB.
  /// * [rawAddData] : Data specified when performing an add operation.
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
  RawQueryBuilder.add({
    required super.target,
    required List<Map<String, dynamic>> this.rawAddData,
    super.returnData = false,
    super.mustAffectAtLeastOne,
    super.serialKey,
    super.cause,
  }) : super.add(addData: []);

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
  RawQueryBuilder.update({
    required super.target,
    required super.queryNode,
    required super.overrideData,
    super.returnData = false,
    super.sortObj,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.update();

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
  RawQueryBuilder.updateOne({
    required super.target,
    required super.queryNode,
    required super.overrideData,
    super.returnData = false,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.updateOne();

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
  RawQueryBuilder.delete({
    required super.target,
    required super.queryNode,
    super.returnData = false,
    super.sortObj,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.delete();

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
  RawQueryBuilder.deleteOne({
    required super.target,
    required super.queryNode,
    super.returnData = false,
    super.mustAffectAtLeastOne = true,
    super.cause,
  }) : super.deleteOne();

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
  /// * [offset] : Offset for front-end paging support.
  /// If specified, data from the specified offset onwards will be retrieved.
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
  /// * [limit] : Use search type only.
  /// The maximum number of search results will be limited to this value.
  /// If specified together with offset or startAfter,
  /// limit number of objects after the specified object will be returned.
  /// If specified together with endBefore,
  /// limit number of objects before the specified object will be returned.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  RawQueryBuilder.search({
    required super.target,
    required super.queryNode,
    super.sortObj,
    super.offset,
    super.startAfter,
    super.endBefore,
    super.limit,
    super.cause,
  }) : super.search();

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
  RawQueryBuilder.searchOne({
    required super.target,
    required super.queryNode,
    super.cause,
  }) : super.searchOne();

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
  /// * [offset] : Offset for front-end paging support.
  /// If specified, data from the specified offset onwards will be retrieved.
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
  RawQueryBuilder.getAll({
    required super.target,
    super.sortObj,
    super.offset,
    super.startAfter,
    super.endBefore,
    super.limit,
    super.cause,
  }) : super.getAll();

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
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  RawQueryBuilder.conformToTemplate({
    required super.target,
    required super.template,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.conformToTemplate();

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
  RawQueryBuilder.renameField({
    required super.target,
    required super.renameBefore,
    required super.renameAfter,
    super.returnData = false,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.renameField();

  /// (en) Gets the number of elements in the specified collection.
  ///
  /// (ja) 指定されたコレクションの要素数を取得します。
  ///
  /// * [target] : The collection name in DB.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  RawQueryBuilder.count({required super.target, super.cause}) : super.count();

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
  RawQueryBuilder.clear({
    required super.target,
    super.mustAffectAtLeastOne,
    super.resetSerial,
    super.cause,
  }) : super.clear();

  /// (en) Clears the specified collection and then add data.
  ///
  /// (ja) 指定されたコレクションをclearした後、dataをAddします。
  ///
  /// * [target] : The collection name in DB.
  /// * [rawAddData] : Data specified when performing an add operation.
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
  RawQueryBuilder.clearAdd({
    required super.target,
    required List<Map<String, dynamic>> this.rawAddData,
    super.returnData = false,
    super.mustAffectAtLeastOne,
    super.serialKey,
    super.resetSerial,
    super.cause,
  }) : super.clearAdd(addData: []);

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
  RawQueryBuilder.removeCollection({
    required super.target,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.removeCollection();

  /// (en) Merges collections according to the specified template and
  /// creates a new collection.
  /// This query is special and cannot be included as part of a
  /// transaction query.
  /// Also, any callbacks associated with the target collection will not be
  /// called when it is executed.
  /// This is a maintenance function for administrators who need to change
  /// the database structure.
  /// Normally, you should design your database so that it does not need to
  /// be called.
  ///
  /// (ja) 指定されたテンプレートに沿ってコレクションをマージし、
  /// 新しいコレクションを作成します。
  /// このクエリは特殊で、トランザクションクエリの一部として含めることはできません。
  /// また、実行時には対象のコレクションに紐付いたコールバックも呼ばれません。
  /// これはDBの構造変更が必要な管理者のためのメンテナンス機能であり、
  /// 通常はこれを呼び出さないでも問題ない設計にしてください。
  ///
  /// * [mergeQueryParams] : Parameter object specifically for merge queries.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : Optional metadata for auditing or logging.
  /// Useful in high-security environments or for autonomous AI programs
  /// to record the reason or initiator of a query.
  RawQueryBuilder.merge({
    required super.mergeQueryParams,
    super.mustAffectAtLeastOne = true,
    super.cause,
  }) : super.merge();

  /// (en) This method can be used if you want to change only the search position.
  ///
  /// (ja) 検索位置だけを変更したい場合に利用できるメソッドです。
  ///
  /// * [newOffset] : Offset for front-end paging support.
  /// If specified, data from the specified offset onwards will be retrieved.
  @override
  RawQueryBuilder setOffset(int? newOffset) {
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
  @override
  RawQueryBuilder setStartAfter(Map<String, dynamic>? newStartAfter) {
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
  @override
  RawQueryBuilder setEndBefore(Map<String, dynamic>? newEndBefore) {
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
  @override
  RawQueryBuilder setLimit(int? newLimit) {
    limit = newLimit;
    return this;
  }

  /// (en) Commit the content and convert it into a query object.
  ///
  /// (ja) 内容を確定してクエリーオブジェクトに変換します。
  @override
  Query build() {
    return Query(
      target: target,
      type: type,
      addData: rawAddData,
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
      mergeQueryParams: mergeQueryParams,
      cause: cause,
    );
  }
}
