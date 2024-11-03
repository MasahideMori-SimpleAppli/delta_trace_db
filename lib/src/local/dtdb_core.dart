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
  /// * [localModeSID] : ローカルモード、またはサーバーサイドDartで使用する、
  /// 既に認証されたユーザーのSID。
  Future<DTDBServerResponse> operate(List<DTDBDelta> deltaList,
      {String localModeSID = "local_user"}) {

    
    
  }
  
  
}