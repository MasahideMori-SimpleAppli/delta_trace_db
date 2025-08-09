import 'package:file_state_manager/file_state_manager.dart';
import '../../delta_trace_db.dart';

/// (en) This is a query class for DB operations. It is usually built using
/// QueryBuilder.
/// This class allows you to set the operation target and operation type,
/// as well as specify paging and
/// Track operations by Cause. If you output this class directly to a log on
/// the server side, the log will be a complete history of DB operations.
///
/// (ja) DB操作用のクエリクラスです。通常はQueryBuilderを使用して構築されます。
/// このクラスは、操作対象の設定、操作の種類の設定の他、ページングの指定や
/// Causeによる操作追跡機能を持っています。このクラスをサーバー側でそのままログに出力すると、
/// そのログは完全なDB操作の履歴になります。
class Query extends CloneableFile {
  static const String className = "Query";
  static const String version = "2";

  String target;
  EnumQueryType type;
  List<Map<String, dynamic>>? addData;
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
  bool returnData;
  bool mustAffectAtLeastOne;
  Cause? cause;

  /// Note: I recommend not using this class as is,
  /// but rather using the more convenient QueryBuilder.
  ///
  /// * [target] : The collection name in DB.
  /// * [type] : The query type.
  /// * [addData] : Use add type only.
  /// Data specified when performing an add operation.
  /// Typically, this is assigned the list that results from calling toDict on
  /// a subclass of ClonableFile.
  /// * [overrideData] : Use update or updateOne type only.
  /// This is not a serialized version of the full class,
  /// but a dictionary containing only the parameters you want to update.
  /// * [template] : Use conformToTemplate type only.
  /// Specify this when changing the structure of the DB class.
  /// Fields that do not exist in the existing structure but exist in the
  /// template will be added with the template value as the initial value.
  /// Fields that do not exist in the template will be deleted.
  /// * [queryNode] : This is the node object used for the search.
  /// You can build queries by combining the various nodes defined in
  /// comparison_node.dart.
  /// * [sortObj] : An object for sorting the return values.
  /// SingleSort or MultiSort can be used.
  /// If you set returnData to true, the return values of an update or delete
  /// query will be sorted by this object.
  /// * [offset] : Use search type only.
  /// An offset for paging support in the front end.
  /// This is only valid when sorting is specified, and allows you to specify
  /// that the results returned will be from a specific index after sorting.
  /// * [startAfter] : Use search type only.
  /// If you pass in a serialized version of a search result
  /// object, the search will return results from objects after that object,
  /// and if an offset is specified, it will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  /// * [endBefore] : Use search type only.
  /// If you pass in a serialized version of a search result
  /// object, the search will return results from the object before that one,
  /// and any offset or startAfter specified will be ignored.
  /// This does not work if there are multiple identical objects because it
  /// compares the object values, and is slightly slower than specifying an
  /// offset, but it works fine even if new objects are added during the search.
  /// * [renameBefore] : Use rename type only.
  /// The old variable name when querying for a rename.
  /// * [renameAfter] : Use rename type only.
  /// The new name of the variable when querying for a rename.
  /// * [limit] : Use search type only.
  /// The maximum number of search results will be limited to this value.
  /// If specified together with offset or startAfter,
  /// limit number of objects after the specified object will be returned.
  /// If specified together with endBefore,
  /// limit number of objects before the specified object will be returned.
  /// * [returnData] : If true, return the changed objs.
  /// Not valid for clear and clearAdd.
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
  Query({
    required this.target,
    required this.type,
    this.addData,
    this.overrideData,
    this.template,
    this.queryNode,
    this.sortObj,
    this.offset,
    this.startAfter,
    this.endBefore,
    this.renameBefore,
    this.renameAfter,
    this.limit,
    this.returnData = false,
    this.mustAffectAtLeastOne = true,
    this.cause,
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory Query.fromDict(Map<String, dynamic> src) {
    return Query(
      target: src["target"],
      type: EnumQueryType.values.byName(src["type"]),
      addData: src["addData"] != null
          ? (src["addData"] as List).cast<Map<String, dynamic>>()
          : null,
      overrideData: src["overrideData"],
      template: src["template"],
      queryNode: src["queryNode"] != null
          ? QueryNode.fromDict(src["queryNode"])
          : null,
      sortObj: src["sortObj"] != null
          ? SingleSort.fromDict(src["sortObj"])
          : null,
      offset: src["offset"],
      startAfter: src["startAfter"],
      endBefore: src["endBefore"],
      renameBefore: src["renameBefore"],
      renameAfter: src["renameAfter"],
      limit: src["limit"],
      returnData: src["returnData"],
      mustAffectAtLeastOne: src["mustAffectAtLeastOne"],
      cause: src["cause"] != null ? Cause.fromDict(src["cause"]) : null,
    );
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "target": target,
      "type": type.name,
      "addData": addData != null
          ? (UtilCopy.jsonableDeepCopy(addData) as List)
                .cast<Map<String, dynamic>>()
          : null,
      "overrideData": UtilCopy.jsonableDeepCopy(overrideData),
      "template": UtilCopy.jsonableDeepCopy(template),
      "queryNode": queryNode?.toDict(),
      "sortObj": sortObj?.toDict(),
      "offset": offset,
      "startAfter": UtilCopy.jsonableDeepCopy(startAfter),
      "endBefore": UtilCopy.jsonableDeepCopy(endBefore),
      "renameBefore": renameBefore,
      "renameAfter": renameAfter,
      "limit": limit,
      "returnData": returnData,
      "mustAffectAtLeastOne": mustAffectAtLeastOne,
      "cause": cause?.toDict(),
    };
  }

  @override
  Query clone() {
    return Query.fromDict(toDict());
  }
}
