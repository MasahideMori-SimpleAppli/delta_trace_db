import 'dart:async';
import 'dart:convert';

import 'package:delta_trace_db/src/enum/enum_server_response_status.dart';
import 'package:delta_trace_db/src/network/util_check_url.dart';
import 'package:delta_trace_db/src/server_response/dtdb_server_response.dart';
import 'package:delta_trace_db/src/server_response/util_server_response.dart';
import 'package:delta_trace_db/src/static_fields/f_grant_type.dart';
import 'package:delta_trace_db/src/static_fields/f_json_keys_from_server.dart';
import 'package:delta_trace_db/src/static_fields/f_json_keys_to_server.dart';
import 'package:http/http.dart' as http;

/// (en) A class for managing JWT tokens and controlling login.
/// You can extend this class to provide your own authentication method.
///
/// (ja) JWTトークンの管理とログイン制御のためのクラスです。
/// このクラスを拡張して使用することで、独自の認証方法に置き換えることが可能です。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-28 20:29:00(now creating)
class DTDBAuthService {
  // parameters
  late final String _signInUrl;
  late final String _refreshUrl;
  late final String _signOutURL;
  late final String? _clientID;
  late final String? _clientSecret;
  late final Duration _timeout;

  String? _accessToken;
  String? _refreshToken;
  int? _accessTokenExpireUnixMS;

  // methods
  /// (en) This is an initialization function. If the endpoint URL is not null,
  /// it will be configured to access the specified server.
  ///
  /// (ja) 初期化関数です。エンドポイントURLがnullではない場合、
  /// 指定サーバーに対してアクセスを行うように構成されます。
  ///
  /// * [signInURL] : The authentication URL.
  /// * [refreshURL] : A URL for reissuing a token using a refresh token.
  /// * [signOutURL] : The URL for signOut (revoke) the token.
  /// * [clientID] : Client ID such as the app name. In this implementation,
  /// use a name that you don't mind leaking to the outside.
  /// * [clientSecret] : The client secret key,
  /// which must never be leaked and is only available for server-side use.
  /// If you are using it on the front end, set it to null.
  /// * [timeout] : Timeout period for server access.
  DTDBAuthService(
      {required String signInURL,
      required String refreshURL,
      required String signOutURL,
      String? clientID,
      String? clientSecret,
      Duration? timeout}) {
    _signInUrl = UtilCheckURL.validateHttpsUrl(signInURL);
    _refreshUrl = UtilCheckURL.validateHttpsUrl(refreshURL);
    _signOutURL = UtilCheckURL.validateHttpsUrl(signOutURL);
    _clientID = clientID;
    _clientSecret = clientSecret;
    _timeout = timeout ?? const Duration(minutes: 1);
  }

  /// サインイン処理を行います。
  Future<DTDBServerResponse> signIn(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(_signInUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              FJsonKeysToServer.grantType: FGrantType.password,
              FJsonKeysToServer.username: email,
              FJsonKeysToServer.password: password,
              FJsonKeysToServer.clientID: _clientID,
              FJsonKeysToServer.clientSecret: _clientSecret,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        // トークンを取得して保存
        final int nowUnixTimeMS = DateTime.now().millisecondsSinceEpoch;
        final tokens = jsonDecode(response.body);
        _accessToken = tokens[FJsonKeysFromServer.accessToken];
        _accessTokenExpireUnixMS = nowUnixTimeMS +
            (int.parse(tokens[FJsonKeysFromServer.expiresIn].toString()) *
                1000);
        _refreshToken = tokens[FJsonKeysFromServer.refreshToken];
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

  /// サインアウト処理を行います。
  /// リフレッシュトークンと共にアクセストークンも無効化され、
  /// 以降はサインインが必要になります。
  Future<DTDBServerResponse> signOut() async {
    try {
      final response = await http
          .post(
            Uri.parse(_signOutURL),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              FJsonKeysToServer.tokenTypeHint: FJsonKeysToServer.refreshToken,
              FJsonKeysToServer.refreshToken: _refreshToken,
              FJsonKeysToServer.clientID: _clientID,
              FJsonKeysToServer.clientSecret: _clientSecret,
            }),
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

  /// JWTトークンを取得します。
  /// キャッシュされたトークンの期限が残っている場合、キャッシュされたトークンが返されます。
  /// トークンが期限切れの場合はリフレッシュトークンを使ってリフレッシュを試みますが、
  /// 失敗した場合はnullを返します。
  /// また、サインイン状態では無い場合もnullが返されます。
  Future<String?> getToken() async {
    if (_refreshToken == null) {
      return null;
    }
    if (_isTokenExpired()) {
      final DTDBServerResponse res = await _refreshAndGetNewToken();
      if (res.resultStatus != EnumSeverResponseStatus.success) {
        return null;
      }
    }
    return _accessToken;
  }

  /// トークンの期限切れをチェックします。
  bool _isTokenExpired() {
    if (_accessTokenExpireUnixMS == null) return true;
    return DateTime.now().millisecondsSinceEpoch > _accessTokenExpireUnixMS!;
  }

  /// リフレッシュトークンを使用して新しいトークンを取得し、キャッシュします。
  Future<DTDBServerResponse> _refreshAndGetNewToken() async {
    if (_refreshToken == null) {
      return UtilServerResponse.signInRequired();
    }
    // サーバーからトークンを取得
    try {
      final response = await http.post(
        Uri.parse(_refreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: {
          FJsonKeysToServer.grantType: FGrantType.refreshToken,
          FJsonKeysToServer.refreshToken: _refreshToken,
          FJsonKeysToServer.clientID: _clientID,
          FJsonKeysToServer.clientSecret: _clientSecret,
        },
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        // トークンを取得して保存
        final int nowUnixTimeMS = DateTime.now().millisecondsSinceEpoch;
        try {
          final Map<String, dynamic> tokens = jsonDecode(response.body);
          _accessToken = tokens[FJsonKeysFromServer.accessToken];
          _accessTokenExpireUnixMS = nowUnixTimeMS +
              (int.parse(tokens[FJsonKeysFromServer.expiresIn].toString()) *
                  1000);
          _refreshToken = tokens[FJsonKeysFromServer.refreshToken];
          return UtilServerResponse.success(response);
        } catch (e) {
          return UtilServerResponse.otherError('Invalid token format');
        }
      } else {
        // リフレッシュトークンが期限切れの場合、クライアント側のトークンをクリアする
        if (response.statusCode == 401) {
          clearToken();
          return UtilServerResponse.signInRequired();
        } else {
          return UtilServerResponse.serverError(response);
        }
      }
    } on TimeoutException catch (_) {
      return UtilServerResponse.timeout();
    } catch (e) {
      return UtilServerResponse.otherError(e);
    }
  }

  /// アクセストークン、及びリフレッシュトークンをクリアします。
  void clearToken() {
    _accessToken = null;
    _accessTokenExpireUnixMS = null;
    _refreshToken = null;
  }
}
