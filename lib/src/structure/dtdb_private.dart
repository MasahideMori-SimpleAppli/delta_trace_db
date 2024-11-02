import 'package:delta_trace_db/src/structure/dtdb_access_layer.dart';

import '../node/dtdb_node.dart';

/// (en) A class for configuring nodes in a database where
/// only private access is allowed.
///
/// (ja) プライベートアクセスのみ許可される領域の、データベースのノードを構成するためのクラス。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:25:52(now creating)
class DTDBPrivate extends DTDBAccessLayer{
  static const String className = "DTDBPrivate";
  static const int version = 1;
  late final String userSID;

  DTDBPrivate(this.userSID);

  DTDBPrivate.fromDict(Map<String, dynamic> src) {
    userSID = src["userSerialID"];
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }

  @override
  DTDBPrivate clone() {
    return DTDBPrivate.fromDict(toDict());
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