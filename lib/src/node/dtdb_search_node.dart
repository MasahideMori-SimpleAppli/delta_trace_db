import 'package:delta_trace_db/src/node/dtdb_data_node.dart';

/// (en) Class used when searching for database nodes.
/// Data search is performed according to the conditions specified in this class.
///
/// (ja) データベースのノードを探索する時に利用するクラス。
/// このクラスで指定した条件に従ってデータの探索が実行されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:05:26
class DTDBSearchNode extends DTDBDataNode{

  DTDBSearchNode(super.nodeName);

}

enum EnumSearchTarget{
  nodeName,
  data,
  creationTimeMS,
  updateTimeMS,
}