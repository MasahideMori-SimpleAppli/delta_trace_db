import '../../delta_trace_db.dart';

/// (en) A builder class for easily constructing queries.
/// This version differs from the normal QueryBuilder in that it passes a Map
/// directly without using a ClonableFile.
///
/// (ja) クエリを簡単に組み立てるためのビルダークラスです。
/// このバージョンは通常のQueryBuilderと異なり、ClonableFileを使用せずにMapを直接渡します。
class RawQueryBuilder extends QueryBuilder {
  List<Map<String, dynamic>>? rawAddData;
  Map<String, dynamic>? rawTemplate;

  /// * [target] : The collection name in DB.
  /// * [rawAddData] : Data specified when performing an add operation.
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
  RawQueryBuilder.add({
    required super.target,
    required this.rawAddData,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.add(addData: null);

  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [overrideData] : This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
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
    required super.returnData,
    super.sortObj,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.update();

  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [overrideData] : This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
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
    required super.returnData,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.updateOne();

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
    required super.returnData,
    super.sortObj,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.delete();

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
    required super.returnData,
    super.mustAffectAtLeastOne = true,
    super.cause,
  }) : super.deleteOne();

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

  /// * [target] : The collection name in DB.
  /// * [rawTemplate] : Specify this when changing the structure of the DB class.
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
    required this.rawTemplate,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.conformToTemplate(template: null);

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
    required super.returnData,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.renameField();

  /// * [target] : The collection name in DB.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  RawQueryBuilder.count({required super.target, super.cause}) : super.count();

  /// * [target] : The collection name in DB.
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
  RawQueryBuilder.clear({
    required super.target,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.clear();

  /// * [target] : The collection name in DB.
  /// * [rawAddData] : Data specified when performing an add operation.
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
  RawQueryBuilder.clearAddAll({
    required super.target,
    required this.rawAddData,
    super.mustAffectAtLeastOne,
    super.cause,
  }) : super.clearAddAll(addData: null);

  /// (en) Commit the content and convert it into a query object.
  ///
  /// (ja) 内容を確定してクエリーオブジェクトに変換します。
  Query build() {
    return Query(
      target: target,
      type: type,
      addData: rawAddData,
      overrideData: overrideData,
      template: rawTemplate,
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
      cause: cause,
    );
  }
}
