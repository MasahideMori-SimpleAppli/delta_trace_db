import 'package:delta_trace_db/src/enum/enum_server_response_status.dart';
import 'package:http/http.dart' as http;

/// (en) This class stores the return values from
/// the server regarding the DeltaTraceDB API.
/// In addition to the decoded response from the server,
/// it also stores error codes, etc.
///
/// (ja) DeltaTraceDBのAPIに関する、サーバーからの戻り値格納用クラスです。
/// サーバーからのデコード済みレスポンス以外に、エラーコードなども格納されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-29 17:36:24
class DTDBServerResponse {
  final http.Response? response;
  final EnumSeverResponseStatus resultStatus;
  final Map<String, dynamic>? resBody;
  final String? error;

  /// * [response] : Http response object.
  /// * [isTokenExpired] : If true, the token has expired and a login process
  /// is required.
  /// * [isTimeOut] : If true, request timeout occurred.
  /// * [resBody] :　The json decode server response body.
  /// * [error] : Null if no error occurred.
  /// It will also be null on timeout.
  DTDBServerResponse(
      this.response, this.resultStatus, this.resBody, this.error);
}
