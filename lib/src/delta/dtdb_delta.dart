import 'package:delta_trace_db/src/delta/enum_crud.dart';
import 'package:delta_trace_db/src/structure/dtdb_access_layer.dart';
import 'package:delta_trace_db/src/node/dtdb_data.dart';
import 'package:file_state_manager/file_state_manager.dart';

/// (en) An object that represents a single operation on a database.
/// This delta unit is used not only to operate the database,
/// but also to record the operation log.
///
/// (ja) データベースに対する１つの操作を表すオブジェクト。
/// このデルタの単位でデータベースの操作だけでなく、操作ログも記録されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:39:49(now creating)
class DTDBDelta extends CloneableFile {
  EnumCRUD crud;
  DTDBAccessLayer target;
  DTDBData data;

  // フロントエンドでこれが作成された時のUNIX時間。
  late final int creationTimeMS;

  // サーバーサイドでのデータ復元時のUNIX時間。
  int? serverReceiveTimeMS;

  // 認証が完了した時点で、サーバーサイドで上書きされるSID。
  String? sid;

  // サーバーサイドで操作が成功した場合はtrueが入る。
  // 認証に失敗した場合や操作に失敗した場合などはfalseが入る。
  bool? isSuccess;

  DTDBDelta(this.crud, this.target, this.data) {
    creationTimeMS = DateTime.now().millisecondsSinceEpoch;
  }

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
