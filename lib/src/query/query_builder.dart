import 'package:file_state_manager/file_state_manager.dart';

import '../../delta_trace_db.dart';

/// (en) A builder class for easily constructing queries.
///
/// (ja) クエリを簡単に組み立てるためのビルダークラスです。
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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.add({
    required this.target,
    required List<CloneableFile> addData,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.serialKey,
    this.cause,
  }) : this.addData = addData,
       type = EnumQueryType.add;

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
  QueryBuilder.update({
    required this.target,
    required QueryNode queryNode,
    required Map<String, dynamic> overrideData,
    this.returnData = false,
    this.sortObj,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : this.queryNode = queryNode,
       this.overrideData = overrideData,
       type = EnumQueryType.update;

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
  QueryBuilder.updateOne({
    required this.target,
    required QueryNode queryNode,
    required Map<String, dynamic> overrideData,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : this.queryNode = queryNode,
       this.overrideData = overrideData,
       type = EnumQueryType.updateOne;

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
  QueryBuilder.delete({
    required this.target,
    required QueryNode queryNode,
    this.returnData = false,
    this.sortObj,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : this.queryNode = queryNode,
       type = EnumQueryType.delete;

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
  QueryBuilder.deleteOne({
    required this.target,
    required QueryNode queryNode,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : this.queryNode = queryNode,
       type = EnumQueryType.deleteOne;

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
  QueryBuilder.search({
    required this.target,
    required QueryNode queryNode,
    this.sortObj,
    this.offset,
    this.startAfter,
    this.endBefore,
    this.limit,
    this.cause,
  }) : this.queryNode = queryNode,
       type = EnumQueryType.search;

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
  QueryBuilder.getAll({required this.target, this.sortObj, this.cause})
    : type = EnumQueryType.getAll;

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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.conformToTemplate({
    required this.target,
    required Map<String, dynamic> template,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : this.template = template,
       type = EnumQueryType.conformToTemplate;

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
  QueryBuilder.renameField({
    required this.target,
    required String renameBefore,
    required String renameAfter,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  }) : this.renameBefore = renameBefore,
       this.renameAfter = renameAfter,
       type = EnumQueryType.renameField;

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
  QueryBuilder.count({required this.target, this.cause})
    : type = EnumQueryType.count;

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
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.clearAdd({
    required this.target,
    required List<CloneableFile> addData,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.serialKey,
    this.resetSerial = false,
    this.cause,
  }) : this.addData = addData,
       type = EnumQueryType.clearAdd;

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
