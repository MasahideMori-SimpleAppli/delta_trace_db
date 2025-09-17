import '../../delta_trace_db.dart';

/// (en) A builder class for easily constructing queries.
/// This version differs from the normal QueryBuilder in that it passes a Map
/// directly without using a ClonableFile.
///
/// (ja) クエリを簡単に組み立てるためのビルダークラスです。
/// このバージョンは通常のQueryBuilderと異なり、ClonableFileを使用せずにMapを直接渡します。
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  RawQueryBuilder.add({
    required super.target,
    required List<Map<String, dynamic>> rawAddData,
    super.returnData = false,
    super.mustAffectAtLeastOne,
    super.serialKey,
    super.cause,
  }) : this.rawAddData = rawAddData,
       super.add(addData: []);

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
  /// * [sortObj] : An object for sorting the search return values.
  /// SingleSort or MultiSort can be used.
  /// If you set returnData to true, the return values of an update or delete
  /// query will be sorted by this object.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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
  /// SingleSort or MultiSort can be used.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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
  /// SingleSort or MultiSort can be used.
  /// If you set returnData to true, the return values of an update or delete
  /// query will be sorted by this object.
  /// * [offset] : An offset for paging support in the front end.
  /// This is only valid when sorting is specified, and allows you to specify
  /// that the results returned will be from a specific index after sorting.
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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

  /// (en) Gets all items in the specified collection.
  ///
  /// (ja) 指定されたコレクションの全てのアイテムを取得します。
  ///
  /// * [target] : The collection name in DB.
  /// * [sortObj] : An object for sorting the return values.
  /// SingleSort or MultiSort can be used.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  RawQueryBuilder.getAll({required super.target, super.sortObj, super.cause})
    : super.getAll();

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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  RawQueryBuilder.conformToTemplate({
    required super.target,
    required Map<String, dynamic> template,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.conformToTemplate(template: template);

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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  RawQueryBuilder.count({required super.target, super.cause}) : super.count();

  /// (en) Clears the specified collection.
  ///
  /// (ja) 指定されたコレクションをclearします。
  ///
  /// * [target] : The collection name in DB.
  /// * [mustAffectAtLeastOne] : If true, the operation will be marked as
  /// failed if it affects 0 objects.
  /// If the operation is treated as a failure, the isSuccess flag of the
  /// returned QueryResult will be set to false.
  /// * [resetSerial] : If true, resets the managed serial number to 0 on
  /// a clear or clearAdd query.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  RawQueryBuilder.clearAdd({
    required super.target,
    required List<Map<String, dynamic>> rawAddData,
    super.returnData = false,
    super.mustAffectAtLeastOne,
    super.serialKey,
    super.resetSerial,
    super.cause,
  }) : this.rawAddData = rawAddData,
       super.clearAdd(addData: []);

  /// (en) Commit the content and convert it into a query object.
  ///
  /// (ja) 内容を確定してクエリーオブジェクトに変換します。
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
      cause: cause,
    );
  }
}
