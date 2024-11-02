import 'package:file_state_manager/file_state_manager.dart';

/// (en)This is a data class stored in a database node.
/// In addition to user data, it also holds information
/// such as the data creation date.
///
/// (ja)データベースのノードに格納されるデータクラスです。
/// ユーザー用のデータの他に、データ作成日などの情報も保持されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:52:11(now creating)
class DTDBData extends CloneableFile{
  static const String className = "DTDBData";
  static const int version = 1;

  @override
  CloneableFile clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }

}