import 'dart:async';
import 'dart:convert';
import 'package:delta_trace_db/src/delta/dtdb_delta.dart';
import 'package:delta_trace_db/src/dtdb_auth_service.dart';
import 'package:delta_trace_db/src/server_response/dtdb_server_response.dart';
import 'package:delta_trace_db/src/server_response/util_server_response.dart';
import 'package:http/http.dart' as http;

import 'package:delta_trace_db/src/local/dtdb_core.dart';

import 'network/util_check_url.dart';

/// (en) This is a class for operating DeltaTraceDB.
/// Various operations can be performed from this object.
/// This object operates as a singleton.
///
/// (ja) DeltaTraceDBの操作用クラスです。各種操作をこのオブジェクトから行えます。
/// このオブジェクトはシングルトンで動作します。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-27 16:50:43(now creating)
class DeltaTraceDatabase {
  // Singleton
  static final DeltaTraceDatabase _instance = DeltaTraceDatabase._internal();

  DeltaTraceDatabase._internal();

  factory DeltaTraceDatabase() {
    return _instance;
  }

  // Singleton code end.

  // parameters
  late final DTDBAuthService? _authService;
  late final String? _endpointUrl;
  late final Duration _timeout;

  bool get isLocalMode => _endpointUrl == null;

  // For local DB
  DTDBCore? _dbCore;

  // methods
  /// (en) This is an initialization function. If the endpoint URL is not null,
  /// it will be configured to access the specified server.
  /// If the endpoint URL is null, it will be initialized in local mode.
  ///
  /// (ja) 初期化関数です。エンドポイントURLがnullではない場合、
  /// 指定サーバーに対してアクセスを行うように構成されます。
  /// エンドポイントURLがnullの場合は、ローカルモードで初期化されます。
  ///
  /// * [authService] : This is the service class used for authentication.
  /// This class manages tokens and logins.
  /// If this is null, the access will be performed without credentials.
  /// * [endpointUrl] : The URL of the database implemented as an https server.
  /// * [timeout] : Timeout period for server access.
  Future<void> initialize(
      {DTDBAuthService? authService,
      String? endpointUrl,
      Duration? timeout}) async {
    _authService = authService;
    _endpointUrl =
        endpointUrl != null ? UtilCheckURL.validateHttpsUrl(endpointUrl) : null;
    _timeout = timeout ?? const Duration(minutes: 1);
    if (isLocalMode) {
      // ローカルデータベースのセットアップ
      _dbCore = DTDBCore();
    }
  }

  /// Databaseに対して操作を行います。
  /// * [localModeSID] : ローカルモード、またはサーバーサイドDartで使用する、
  /// 既に認証されたユーザーのSID。
  Future<DTDBServerResponse> operate(DTDBDelta delta,
      {String localModeSID = "local_user"}) {
    if (isLocalMode) {
      return _dbCore!.operate([delta], localModeSID: localModeSID);
    } else {
      return _sendToServer(_endpointUrl!, [delta]);
    }
  }

  /// Databaseに対して複数の操作を行います。
  /// * [localModeSID] : ローカルモード、またはサーバーサイドDartで使用する、
  /// 既に認証されたユーザーのSID。
  Future<DTDBServerResponse> multiOperate(List<DTDBDelta> deltaList,
      {String localModeSID = "local_user"}) {
    if (isLocalMode) {
      return _dbCore!.operate(deltaList, localModeSID: localModeSID);
    } else {
      return _sendToServer(_endpointUrl!, deltaList);
    }
  }

  /// Databaseと同様のスキームで処理を行う、特定のエンドポイントに対して操作を行います。
  /// これはネットワークが必須のため、ローカルモードでは動作しません。
  /// * [endpointUrl] : DeltaTraceDatabaseと同様のスキームで処理を行えるエンドポイントのURL。
  /// これを用いると、検索結果に追加の独自処理を加えたい場合などに、クラウド関数を挟んで処理できます。
  Future<DTDBServerResponse> operateTo(String endpointUrl, DTDBDelta delta) {
    return _sendToServer(endpointUrl, [delta]);
  }

  /// Databaseと同様のスキームで処理を行う、特定のエンドポイントに対して複数の操作を行います。
  /// これはネットワークが必須のため、ローカルモードでは動作しません。
  /// * [endpointUrl] : DeltaTraceDatabaseと同様のスキームで処理を行えるエンドポイントのURL。
  /// これを用いると、検索結果に追加の独自処理を加えたい場合などに、クラウド関数を挟んで処理できます。
  Future<DTDBServerResponse> multiOperateTo(
      String endpointUrl, List<DTDBDelta> deltaList) {
    return _sendToServer(endpointUrl, deltaList);
  }

  /// サーバーにデータをPOSTします。
  Future<DTDBServerResponse> _sendToServer(
      String endpointUrl, List<DTDBDelta> deltaList) async {
    List<Map<String, dynamic>> mDeltaList = [];
    for (DTDBDelta i in deltaList) {
      mDeltaList.add(i.toDict());
    }
    if (_authService == null) {
      // 認証なしでのHTTPリクエスト処理
      try {
        final response = await http
            .post(
              Uri.parse(endpointUrl),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({"deltaList": mDeltaList}),
            )
            .timeout(_timeout);
        if (response.statusCode == 200) {
          return UtilServerResponse.success(response);
        } else {
          return UtilServerResponse.serverError(response);
        }
      } on TimeoutException catch (_) {
        return UtilServerResponse.timeout();
      } catch (e) {
        return UtilServerResponse.otherError(e);
      }
    } else {
      // ステートレス認証でのHTTPリクエスト処理
      final String? authToken = await _authService!.getToken();
      if (authToken == null) {
        return UtilServerResponse.signInRequired();
      }
      try {
        final response = await http
            .post(
              Uri.parse(endpointUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: jsonEncode(mDeltaList),
            )
            .timeout(_timeout);
        if (response.statusCode == 200) {
          return UtilServerResponse.success(response);
        } else {
          return UtilServerResponse.serverError(response);
        }
      } on TimeoutException catch (_) {
        return UtilServerResponse.timeout();
      } catch (e) {
        return UtilServerResponse.otherError(e);
      }
    }
  }
}
