import 'package:delta_trace_db/src/node/structure/enum_dtdb_layer_type.dart';

import '../search/dtdb_search_obj.dart';
import 'dtdb_access_layer.dart';

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

  DTDBLimited(this.userSID, this.groupName): super(EnumDTDBLayerType.limited);

  factory DTDBLimited.fromDict(Map<String, dynamic> src) {
    return DTDBLimited(src["userSID"], src["groupName"]);
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
  DTDBAccessLayer addSearchObj(DTDBSearchObj node) {
    // TODO: implement addNode
    throw UnimplementedError();
  }

  @override
  void addSearchObjs(List<DTDBSearchObj> nodes) {
    // TODO: implement addNodes
  }

}