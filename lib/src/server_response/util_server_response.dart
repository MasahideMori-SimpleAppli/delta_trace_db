import 'package:delta_trace_db/src/server_response/dtdb_server_response.dart';
import 'package:delta_trace_db/src/server_response/enum_server_response_status.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// サーバー応答を一定のフォーマットに沿って整形するためのユーティリティです。
class UtilServerResponse {
  /// 成功時のサーバー応答オブジェクトを作成します。
  static DTDBServerResponse success(http.Response response) {
    return DTDBServerResponse(response, EnumSeverResponseStatus.success,
        jsonDecode(response.body), null);
  }

  /// サーバーエラー時のサーバー応答オブジェクトを作成します。
  static DTDBServerResponse serverError(http.Response response) {
    String errorDescription = "";
    Map<String, dynamic> errorBody = {};
    try {
      errorBody = jsonDecode(response.body);
      errorDescription = errorBody["error_description"];
    } catch (e) {
      errorDescription = "Unknown exception.";
    }
    return DTDBServerResponse(response, EnumSeverResponseStatus.serverError,
        errorBody, errorDescription);
  }

  /// タイムアウト時のサーバー応答オブジェクトを作成します。
  static DTDBServerResponse timeout() {
    return DTDBServerResponse(
        null, EnumSeverResponseStatus.timeout, null, null);
  }
  
  /// 認証が必要になった時のサーバー応答オブジェクトを作成します。
  static DTDBServerResponse signInRequired() {
    return DTDBServerResponse(
        null, EnumSeverResponseStatus.signInRequired, null, null);
  }

  /// 通信エラーを含む、その他のエラー発生時のサーバー応答オブジェクトを作成します。
  static DTDBServerResponse otherError(Object e) {
    return DTDBServerResponse(
        null, EnumSeverResponseStatus.otherError, null, e.toString());
  }
}
