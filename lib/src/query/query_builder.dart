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
  CloneableFile? template;
  QueryNode? queryNode;
  AbstractSort? sortObj;
  int? offset = 0;
  Map<String, dynamic>? startAfter;
  Map<String, dynamic>? endBefore;
  String? renameBefore;
  String? renameAfter;
  int? limit;
  bool returnData = false;
  Cause? cause;

  /// * [target] : The collection name in DB.
  /// * [addData] : Data specified when performing an add operation.
  /// Typically, this is assigned the list that results from calling toDict on
  /// a subclass of ClonableFile.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.add({required this.target, required this.addData, this.cause})
    : type = EnumQueryType.add;

  /// * [target] : The collection name in DB.
  /// * [overrideData] : This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [sortObj] : An object for sorting the search return values.
  /// SingleSort or MultiSort can be used.
  /// If you set returnData to true, the return values of an update or delete
  /// query will be sorted by this object.
  /// * [returnData] : If true, return the changed objs.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.update({
    required this.target,
    required this.queryNode,
    required this.overrideData,
    required this.returnData,
    this.sortObj,
    this.cause,
  }) : type = EnumQueryType.update;

  /// * [target] : The collection name in DB.
  /// * [overrideData] : This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [returnData] : If true, return the changed objs.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.updateOne({
    required this.target,
    required this.queryNode,
    required this.overrideData,
    required this.returnData,
    this.cause,
  }) : type = EnumQueryType.updateOne;

  /// * [target] : The collection name in DB.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [sortObj] : An object for sorting the return values.
  /// SingleSort or MultiSort can be used.
  /// * [returnData] : If true, return the changed objs.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.delete({
    required this.target,
    required this.queryNode,
    required this.returnData,
    this.sortObj,
    this.cause,
  }) : type = EnumQueryType.delete;

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
    required this.queryNode,
    this.sortObj,
    this.offset,
    this.startAfter,
    this.endBefore,
    this.limit,
    this.cause,
  }) : type = EnumQueryType.search;

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

  /// * [target] : The collection name in DB.
  /// * [template] : Specify this when changing the structure of the DB class.
  /// Fields that do not exist in the existing structure but exist in the
  /// template will be added with the template value as the initial value.
  /// Fields that do not exist in the template will be deleted.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.conformToTemplate({
    required this.target,
    required this.template,
    this.cause,
  }) : type = EnumQueryType.conformToTemplate;

  /// * [target] : The collection name in DB.
  /// * [renameBefore] : The old variable name when querying for a rename.
  /// * [renameAfter] : The new name of the variable when querying for a rename.
  /// * [returnData] : If true, return the changed objs.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.renameField({
    required this.target,
    required this.renameBefore,
    required this.renameAfter,
    required this.returnData,
    this.cause,
  }) : type = EnumQueryType.renameField;

  /// * [target] : The collection name in DB.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.count({required this.target, this.cause})
    : type = EnumQueryType.count;

  /// * [target] : The collection name in DB.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.clear({required this.target, this.cause})
    : type = EnumQueryType.clear;

  /// * [target] : The collection name in DB.
  /// * [addData] : Data specified when performing an add operation.
  /// Typically, this is assigned the list that results from calling toDict on
  /// a subclass of ClonableFile.
  /// * [cause] : You can add further parameters such as why this query was
  /// made and who made it.
  /// This is useful if you have high security requirements or want to run the
  /// program autonomously using artificial intelligence.
  /// By saving the entire query including this as a log,
  /// the DB history is recorded.
  QueryBuilder.clearAddAll({
    required this.target,
    required this.addData,
    this.cause,
  }) : type = EnumQueryType.clearAdd;

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
      template: template?.toDict(),
      queryNode: queryNode,
      sortObj: sortObj,
      offset: offset,
      startAfter: startAfter,
      endBefore: endBefore,
      renameBefore: renameBefore,
      renameAfter: renameAfter,
      limit: limit,
      returnData: returnData,
      cause: cause,
    );
  }
}
