import 'dart:convert';

import 'package:delta_trace_db/src/local/enum_dtdb_user_type.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:simple_jwt_manager/simple_jwt_manager.dart';
import '../delta/dtdb_delta.dart';
import '../node/dtdb_node.dart';
import '../node/structure/layer/enum_dtdb_layer_type.dart';
import 'package:http/http.dart' as http;

/// (en) This is the core class for local DeltaTraceDB.
///
/// (ja) ローカル用のDeltaTraceDBのコアクラスです。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-27 17:20:37(now creating)
class DTDBCore extends CloneableFile {
  static const String className = "DTDBCore";
  static const int version = 1;
  List<DTDBNode> _nodes = [];

  /// * [nodes] : Specify the list of nodes you want to restore, if any.
  DTDBCore({List<DTDBNode>? nodes}) {
    if (nodes != null) {
      _nodes = nodes;
    }
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory DTDBCore.fromDict(Map<String, dynamic> src) {
    List<DTDBNode> nodes = [];
    for (Map<String, dynamic> i in src["nodes"]) {
      nodes.add(DTDBNode.fromDict(i));
    }
    return DTDBCore(nodes: nodes);
  }

  @override
  CloneableFile clone() {
    return DTDBCore.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    List<Map<String, dynamic>> nodes = [];
    for (DTDBNode i in _nodes) {
      nodes.add(i.toDict());
    }
    return {
      "className": className,
      "version": version,
      "nodes": nodes,
    };
  }

  /// Databaseに対して実行する操作（Delta）をリストで渡します。
  ///
  /// * [localModeSID] : ローカルモードで使用する、既に認証されたユーザーのSID。
  /// * [userType] : ローカルモードで使用する、アクセス元がユーザーなのかシステムなのかの指定。
  /// システムによるアクセスの場合のみ、システムレイヤへのアクセスが許可されます。
  ///
  /// Returns : {"nodeList": serialized DTDBNode list}
  Future<ServerResponse> operate(List<DTDBDelta> deltaList,
      {String localModeSID = "local_user",
      EnumDTDBUserType userType = EnumDTDBUserType.general}) async {
    List<DTDBNode> nodeList = [];
    for (DTDBDelta i in deltaList) {
      switch (i.target.layerType) {
        case EnumDTDBLayerType.public:
          nodeList.add(_operatePublic(i));
          break;
        case EnumDTDBLayerType.limited:
          nodeList.add(_operateLimited(i));
          break;
        case EnumDTDBLayerType.private:
          nodeList.add(_operatePrivate(i));
          break;
        case EnumDTDBLayerType.system:
          nodeList.add(_operateSystem(i));
          break;
      }
    }
    List<Map<String, dynamic>> r = [];
    for (DTDBNode i in nodeList) {
      r.add(i.toDict());
    }
    return UtilServerResponse.success(
        http.Response(jsonEncode({"nodeList": r}), 200));
  }

  DTDBNode _operatePublic(DTDBDelta i) {}

  DTDBNode _operateLimited(DTDBDelta i) {}

  DTDBNode _operatePrivate(DTDBDelta i) {}

  DTDBNode _operateSystem(DTDBDelta i) {}
}
