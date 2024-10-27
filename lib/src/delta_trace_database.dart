import 'dart:async';
import 'dart:convert';
import 'package:delta_trace_db/src/jwt_manager.dart';
import 'package:delta_trace_db/src/server/dtdb_server_response.dart';
import 'package:http/http.dart' as http;

import 'package:delta_trace_db/src/local/delta_trace_database_core.dart';

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
  late final JWTManager _jwtManager;
  late final String? _endpointUrl;
  late final Duration _timeout;

  bool get isRemote => _endpointUrl != null;

  // For local DB
  DeltaTraceDatabaseCore? _dbCore;

  // methods
  /// (en) This is an initialization function. If the endpoint URL is not null,
  /// it will be configured to access the specified server.
  ///
  /// (ja) 初期化関数です。エンドポイントURLがnullではない場合、
  /// 指定サーバーに対してアクセスを行うように構成されます。
  ///
  /// * [jwtManager] : A manager class for obtaining JWT tokens.
  /// You can also design your own authentication by
  /// passing in this extended class.
  /// * [endpointUrl] : The URL of the database implemented as an https server.
  /// * [timeout] : Timeout period for server access.
  Future<void> initialize(JWTManager jwtManager,
      {String? endpointUrl, Duration? timeout}) async {
    _jwtManager = jwtManager;
    _endpointUrl = endpointUrl;
    _timeout = timeout ?? const Duration(minutes: 1);
    if (!isRemote) {
      // ローカルデータベースのセットアップ
      _dbCore = DeltaTraceDatabaseCore();
    }
  }

  // TODO 作成中。
  /// Create操作
  Future<DTDBServerResponse> create(
      String authToken, String collection, Map<String, dynamic> data) async {
    if (isRemote) {
      // サーバーAPIにPOSTリクエストを送信
      return await _sendToServer(data);
    } else {
      // ローカルデータベースにデータを挿入
      return await _dbCore.create(collection, data);
    }
  }

  // TODO 作成中。
  /// Read操作
  Future<DTDBServerResponse> read(String id) async {
    if (isRemote) {
      return await _sendToServer({'id': id});
    } else {
      return await _dbCore.read(id);
    }
  }

  // TODO 作成中。
  /// Update操作
  Future<DTDBServerResponse> update(String id) async {
    if (isRemote) {
      return await _sendToServer({'id': id});
    } else {
      return await _dbCore.update(id);
    }
  }

  // TODO 作成中。
  /// Delete操作
  Future<DTDBServerResponse> delete(String id) async {
    if (isRemote) {
      return await _sendToServer({'id': id});
    } else {
      return await _dbCore.delete(id);
    }
  }

  /// サーバーに認証トークン付のデータをPOSTします。
  Future<DTDBServerResponse> _sendToServer(Map<String, dynamic> data) async {
    final String authToken = await _jwtManager.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken', // 毎回トークンを渡す
    };

    try {
      // HTTPリクエスト処理
      final response = await http
          .post(
            Uri.parse(_endpointUrl!),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return DTDBServerResponse(
          response, false, jsonDecode(response.body), null);
    } on TimeoutException catch (_) {
      // タイムアウトが発生した場合の処理
      return DTDBServerResponse(null, true, null, null);
    } catch (e) {
      return DTDBServerResponse(null, false, null, e.toString());
    }
  }
}
