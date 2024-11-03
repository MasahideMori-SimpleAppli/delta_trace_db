import '../search/dtdb_search_obj.dart';
import 'dtdb_access_layer.dart';


/// (en) An abstract class for a database security layer with
/// serialization capabilities.
///
/// (ja) パブリックなアクセスが許可される領域の、データベースのノードを構成するためのクラス。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:19:48(now creating)
class DTDBPublic extends DTDBAccessLayer{
  static const String className = "DTDBPublic";
  static const int version = 1;

  DTDBPublic();

  factory DTDBPublic.fromDict(Map<String, dynamic> src) {
    return DTDBPublic();
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }

  @override
  DTDBPublic clone() {
    return DTDBPublic.fromDict(toDict());
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