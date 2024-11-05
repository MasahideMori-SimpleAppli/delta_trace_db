import 'package:delta_trace_db/src/local/enum_dtdb_user_type.dart';
import 'package:delta_trace_db/src/server_response/enum_server_response_status.dart';

import '../delta/dtdb_delta.dart';
import '../server_response/dtdb_server_response.dart';

/// (en) This is the core class for local DeltaTraceDB.
///
/// (ja) ローカル用のDeltaTraceDBのコアクラスです。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-27 17:20:37(now creating)
class DTDBCore {
  /// Databaseに対して複数の操作を行います。
  /// * [localModeSID] : ローカルモードで使用する、既に認証されたユーザーのSID。
  /// * [userType] : ローカルモードで使用する、アクセス元がユーザーなのかシステムなのかの指定。
  /// システムによるアクセスの場合のみ、システムレイヤへのアクセスが許可されます。
  Future<DTDBServerResponse> operate(List<DTDBDelta> deltaList,
      {String localModeSID = "local_user",
      EnumDTDBUserType userType = EnumDTDBUserType.general}) async {
    Map<String, dynamic> r = {};
    // TODO

    return DTDBServerResponse(null, EnumSeverResponseStatus.success, r, null);
  }
}
