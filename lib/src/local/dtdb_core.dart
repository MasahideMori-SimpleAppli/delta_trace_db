import 'dart:convert';

import 'package:delta_trace_db/src/local/enum_dtdb_user_type.dart';
import 'package:delta_trace_db/src/node/dtdb_nodes.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:simple_jwt_manager/simple_jwt_manager.dart';
import '../delta/dtdb_delta.dart';
import '../delta/enum_crud.dart';
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
  DTDBNodes _publicNodes = DTDBNodes();
  DTDBNodes _limitedNodes = DTDBNodes();
  DTDBNodes _privateNodes = DTDBNodes();
  DTDBNodes _systemNodes = DTDBNodes();

  /// * [publicNodes] : Pass in any node information you want to restore.
  /// * [limitedNodes] : Pass in any node information you want to restore.
  /// * [privateNodes] : Pass in any node information you want to restore.
  /// * [systemNodes] : Pass in any node information you want to restore.
  DTDBCore(
      {DTDBNodes? publicNodes,
      DTDBNodes? limitedNodes,
      DTDBNodes? privateNodes,
      DTDBNodes? systemNodes}) {
    if (publicNodes != null) {
      _publicNodes = publicNodes;
    }
    if (limitedNodes != null) {
      _limitedNodes = limitedNodes;
    }
    if (privateNodes != null) {
      _privateNodes = privateNodes;
    }
    if (systemNodes != null) {
      _systemNodes = systemNodes;
    }
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory DTDBCore.fromDict(Map<String, dynamic> src) {
    return DTDBCore(
        publicNodes: DTDBNodes.fromDict(src["publicNodes"]),
        limitedNodes: DTDBNodes.fromDict(src["limitedNodes"]),
        privateNodes: DTDBNodes.fromDict(src["privateNodes"]),
        systemNodes: DTDBNodes.fromDict(src["systemNodes"]));
  }

  @override
  CloneableFile clone() {
    return DTDBCore.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "publicNodes": _publicNodes.toDict(),
      "limitedNodes": _limitedNodes.toDict(),
      "privateNodes": _privateNodes.toDict(),
      "systemNodes": _systemNodes.toDict(),
    };
  }

  /// Databaseに対して実行する操作（Delta）をリストで渡します。
  ///
  /// * [sid] : 既に認証されたユーザーのSID。
  /// * [userType] : ローカルモードで使用する、アクセス元がユーザーなのかシステムなのかの指定。
  /// システムによるアクセスの場合のみ、システムレイヤへのアクセスが許可されます。
  ///
  /// Returns : {"nodeList": serialized DTDBNode list}
  Future<ServerResponse> operate(List<DTDBDelta> deltaList,
      {String sid = "localUser",
      EnumDTDBUserType userType = EnumDTDBUserType.general}) async {
    List<DTDBNode> nodeList = [];
    for (DTDBDelta i in deltaList) {
      switch (i.target.layerType) {
        case EnumDTDBLayerType.public:
          nodeList.add(_operatePublic(i, sid));
          break;
        case EnumDTDBLayerType.limited:
          nodeList.add(_operateLimited(i, sid));
          break;
        case EnumDTDBLayerType.private:
          nodeList.add(_operatePrivate(i, sid));
          break;
        case EnumDTDBLayerType.system:
          nodeList.add(_operateSystem(i, sid));
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

  DTDBNode _operatePublic(DTDBDelta i, String sid) {
    switch (i.crud) {
      case EnumCRUD.create:
        // TODO: Handle this case.
        break;
      case EnumCRUD.read:
        // TODO: Handle this case.
        break;
      case EnumCRUD.update:
        // TODO: Handle this case.
        break;
      case EnumCRUD.delete:
        // TODO: Handle this case.
        break;
    }
  }

  DTDBNode _operateLimited(DTDBDelta i, String sid) {
    switch (i.crud) {
      case EnumCRUD.create:
        // TODO: Handle this case.
        break;
      case EnumCRUD.read:
        // TODO: Handle this case.
        break;
      case EnumCRUD.update:
        // TODO: Handle this case.
        break;
      case EnumCRUD.delete:
        // TODO: Handle this case.
        break;
    }
  }

  DTDBNode _operatePrivate(DTDBDelta i, String sid) {
    switch (i.crud) {
      case EnumCRUD.create:
        // TODO: Handle this case.
        break;
      case EnumCRUD.read:
        // TODO: Handle this case.
        break;
      case EnumCRUD.update:
        // TODO: Handle this case.
        break;
      case EnumCRUD.delete:
        // TODO: Handle this case.
        break;
    }
  }

  DTDBNode _operateSystem(DTDBDelta i, String sid) {
    switch (i.crud) {
      case EnumCRUD.create:
        // TODO: Handle this case.
        break;
      case EnumCRUD.read:
        // TODO: Handle this case.
        break;
      case EnumCRUD.update:
        // TODO: Handle this case.
        break;
      case EnumCRUD.delete:
        // TODO: Handle this case.
        break;
    }
  }
}
