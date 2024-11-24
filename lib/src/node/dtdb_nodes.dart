import 'package:file_state_manager/file_state_manager.dart';

import 'dtdb_node.dart';

/// レイヤー単位でノード情報を構成・操作するためのクラス。
class DTDBNodes extends CloneableFile {
  static const String className = "DTDBNodes";
  static const int version = 1;

  /// キーがPath。値が対応するノード。
  /// SpBMLのような構造で、全てのノードが名前付きになっている。
  /// SpBMLのように、parentとchildrenの情報を持っていうので、そこから検索できる。
  Map<String, DTDBNode> _nodes = {};

  /// [nodes] : Pass if you want to restore managed node data.
  DTDBNodes({Map<String, DTDBNode>? nodes}) {
    if (nodes != null) {
      _nodes = nodes;
    }
  }

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory DTDBNodes.fromDict(Map<String, dynamic> src) {
    Map<String, DTDBNode> nodes = {};
    for (String key in src["nodes"]) {
      nodes[key] = DTDBNode.fromDict(src["nodes"][key]);
    }
    return DTDBNodes(nodes: nodes);
  }

  @override
  CloneableFile clone() {
    return DTDBNodes.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    Map<String, Map<String, dynamic>> nodes = {};
    for (String key in _nodes.keys) {
      nodes[key] = _nodes[key]!.toDict();
    }
    return {"className": className, "version": version, "nodes": nodes};
  }
}
