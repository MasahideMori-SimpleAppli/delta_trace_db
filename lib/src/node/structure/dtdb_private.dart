import '../search/dtdb_search_obj.dart';
import 'dtdb_access_layer.dart';
import 'enum_dtdb_layer_type.dart';

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

  DTDBPrivate(this.userSID): super(EnumDTDBLayerType.private);

  factory DTDBPrivate.fromDict(Map<String, dynamic> src) {
    return DTDBPrivate(src["userSerialID"]);
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
  DTDBAccessLayer addSearchObj(DTDBSearchObj node) {
    // TODO: implement addNode
    throw UnimplementedError();
  }

  @override
  void addSearchObjs(List<DTDBSearchObj> nodes) {
    // TODO: implement addNodes
  }

}