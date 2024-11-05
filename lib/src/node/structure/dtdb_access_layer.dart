import 'package:delta_trace_db/src/node/structure/enum_dtdb_layer_type.dart';
import 'package:file_state_manager/file_state_manager.dart';

import '../search/dtdb_search_obj.dart';

/// (en) An abstract class for a database security layer with
/// serialization capabilities.
///
/// (ja) シリアライズ機能を持つ、データベースのセキュリティレイヤの抽象クラス。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:05:26
abstract class DTDBAccessLayer extends CloneableFile{

  EnumDTDBLayerType layerType;

  /// Normal constructor.
  DTDBAccessLayer(this.layerType);

  factory DTDBAccessLayer.fromDict(Map<String, dynamic> src) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toDict();

  /// (en) Adds a search object to be accessed.
  /// The nodes to be accessed are configured in the order in which this is
  /// called, The final node reached becomes the database to be accessed.
  ///
  /// (ja) 探索用オブジェクトを追加します。
  /// これを呼び出した順にアクセス先が構成され、
  /// 最終的な到達ノードがデータベースのアクセス先になります。
  ///
  /// * [node] : The node.
  ///
  /// Returns : This object.
  DTDBAccessLayer addSearchObj(DTDBSearchObj node);

  /// (en) Adds all the search objects at once.
  /// The order of the nodes to be accessed is determined by
  /// the order of the array,
  /// and the final node to be reached becomes the database destination.
  ///
  /// (ja) 探索用オブジェクトを一括で追加します。
  /// 配列の順番の通りにアクセス先が構成され、
  /// 最終的な到達ノードがデータベースのアクセス先になります。
  ///
  /// * [nodes] : The node names array.
  void addSearchObjs(List<DTDBSearchObj> nodes);

}