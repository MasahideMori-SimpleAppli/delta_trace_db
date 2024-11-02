import 'package:file_state_manager/file_state_manager.dart';

/// (en) A abstract class that represents a single node in a database.
/// The array of this class represents the position of the target node.
///
/// (ja) データベースの単一のノードを表す抽象クラス。
/// このクラスは基本クラスであり、これを拡張したクラスを使用する必要があります。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:05:26
abstract class DTDBNode extends CloneableFile {
  // アクセスレイヤー構成時に追加される、このノードの深さを表す値。
  int? depth;
}
