import '../../search/dtdb_search_obj.dart';
import 'dtdb_access_layer.dart';
import 'enum_dtdb_layer_type.dart';


/// (en) An abstract class for a database security layer with
/// serialization capabilities.
///
/// (ja) パブリックなアクセスが許可される領域の、データベースのノードを構成するためのクラス。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-05 18:46:11(now creating)
class DTDBSystem extends DTDBAccessLayer{
  static const String className = "DTDBSystem";
  static const int version = 1;

  DTDBSystem(): super(EnumDTDBLayerType.public);

  factory DTDBSystem.fromDict(Map<String, dynamic> src) {
    return DTDBSystem();
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }

  @override
  DTDBSystem clone() {
    return DTDBSystem.fromDict(toDict());
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