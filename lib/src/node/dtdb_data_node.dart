import 'package:file_state_manager/file_state_manager.dart';

/// (en) A class that represents a single node in a database.
/// The array of this class represents the position of the target node.
///
/// (ja) データベースの単一のノードを表すクラス。
/// このクラスの配列で対象ノードの位置が表現されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:05:26
class DTDBDataNode extends CloneableFile {
  late final String nodeName;

  // アクセスレイヤー構成時に追加される、このノードの深さを表す値。
  int? depth;

  /// * [nodeName] : The node name.
  DTDBDataNode(this.nodeName);

  DTDBDataNode.fromDict(Map<String, dynamic> src) {
    nodeName = src["nodeName"];
  }

  @override
  Map<String, dynamic> toDict() {
    return {"nodeName": nodeName, "depth": depth};
  }

  @override
  DTDBDataNode clone() {
    return DTDBDataNode.fromDict(toDict());
  }

  @override
  bool operator ==(Object other) {
    if (other is DTDBDataNode) {
      return nodeName == other.nodeName && depth == other.depth;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll([nodeName, depth]);
  }
}
