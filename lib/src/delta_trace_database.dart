import 'dart:async';
import 'dart:convert';
import 'package:delta_trace_db/src/dtdb_auth_service.dart';
import 'package:delta_trace_db/src/server_response/dtdb_server_response.dart';
import 'package:delta_trace_db/src/server_response/util_server_response.dart';
import 'package:http/http.dart' as http;

import 'package:delta_trace_db/src/local/delta_trace_database_core.dart';

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
  DeltaTraceDatabaseCore? _dbCore;

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
      _dbCore = DeltaTraceDatabaseCore();
    }
  }

  // TODO 作成中。
  /// Create操作
  Future<DTDBServerResponse> create(Map<String, dynamic> data) async {
    if (isLocalMode) {
      // ローカルデータベースにデータを挿入
      return await _dbCore.create(data);
    } else {
      // サーバーAPIにPOSTリクエストを送信
      return await _sendToServer(data);
    }
  }

  // TODO 作成中。
  /// Read操作
  Future<DTDBServerResponse> read(String id) async {
    if (isLocalMode) {
      return await _dbCore.read(id);
    } else {
      return await _sendToServer({'id': id});
    }
  }

  // TODO 作成中。
  /// Update操作
  Future<DTDBServerResponse> update(String id) async {
    if (isLocalMode) {
      return await _dbCore.update(id);
    } else {
      return await _sendToServer({'id': id});
    }
  }

  // TODO 作成中。
  /// Delete操作
  Future<DTDBServerResponse> delete(String id) async {
    if (isLocalMode) {
      return await _dbCore.delete(id);
    } else {
      return await _sendToServer({'id': id});
    }
  }

  /// サーバーにデータをPOSTします。
  Future<DTDBServerResponse> _sendToServer(Map<String, dynamic> data) async {
    if (_authService == null) {
      try {
        // 認証なしでのHTTPリクエスト処理
        final response = await http
            .post(
              Uri.parse(_endpointUrl!),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(data),
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
      final String? authToken = await _authService!.getToken();
      if (authToken == null) {
        return UtilServerResponse.signInRequired();
      }
      try {
        // ステートレス認証でのHTTPリクエスト処理
        final response = await http
            .post(
              Uri.parse(_endpointUrl!),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: jsonEncode(data),
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
