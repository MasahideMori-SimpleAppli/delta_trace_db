import 'package:delta_trace_db/src/structure/dtdb_access_layer.dart';
import '../node/dtdb_node.dart';

/// (en) A class for configuring nodes in a database where
/// only limited access is allowed.
///
/// (ja) 制限付きアクセスのみ許可される領域の、データベースのノードを構成するためのクラス。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:25:52(now creating)
class DTDBLimited extends DTDBAccessLayer{
  static const String className = "DTDBLimited";
  static const int version = 1;
  late final String userSID;
  late final String groupName;

  DTDBLimited(this.userSID, this.groupName);

  DTDBLimited.fromDict(Map<String, dynamic> src) {
    userSID = src["userSID"];
    groupName = src["groupName"];
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }

  @override
  DTDBLimited clone() {
    return DTDBLimited.fromDict(toDict());
  }

  @override
  DTDBAccessLayer addNode(DTDBNode node) {
    // TODO: implement addNode
    throw UnimplementedError();
  }

  @override
  void addNodes(List<DTDBNode> nodes) {
    // TODO: implement addNodes
  }

}