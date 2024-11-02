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
class DTDBDataNode extends CloneableFile{
  late final String nodeName;

  /// * [nodeName] : The node name.
  DTDBDataNode(this.nodeName);

  DTDBDataNode.fromDict(Map<String, dynamic> src) {
    nodeName = src["nodeName"];
  }

  @override
  Map<String, dynamic> toDict() {
    return {"nodeName": nodeName};
  }

  @override
  DTDBDataNode clone() {
    return DTDBDataNode.fromDict(toDict());
  }
}
