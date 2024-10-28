import 'dart:convert';

import 'package:http/http.dart' as http;

// TODO 後でローカルモード用の実装を追加する必要がある。
/// (en) A class for managing JWT tokens and controlling login.
/// You can extend this class to provide your own authentication method.
///
/// (ja) JWTトークンの管理とログイン制御のためのクラスです。
/// このクラスを拡張して使用することで、独自の認証方法に置き換えることが可能です。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-28 20:29:00(now creating)
class DTDAuthService {
  // parameters
  late final String? _authUrl;
  late final String? _clientID;
  late final String? _clientSecret;

  bool get isRemote => _authUrl != null;
  String? _accessToken;
  String? _refreshToken;
  int? _accessTokenExpireUnixMS;
  int? _refreshTokenExpireUnixMS;

  // methods
  /// (en) This is an initialization function. If the endpoint URL is not null,
  /// it will be configured to access the specified server.
  ///
  /// (ja) 初期化関数です。エンドポイントURLがnullではない場合、
  /// 指定サーバーに対してアクセスを行うように構成されます。
  ///
  /// * [authUrl] : The authentication URL.
  /// If null, this class will be initialized for local mode.
  /// * [clientID] : Client ID such as the app name. In this implementation,
  /// use a name that you don't mind leaking to the outside.
  /// * [clientSecret] : The client secret key,
  /// which must never be leaked and is only available for server-side use.
  /// If you are using it on the front end, set it to null.
  DTDAuthService(
      {required String? authUrl, String? clientID, String? clientSecret}) {
    _authUrl = authUrl;
    _clientID = clientID;
    _clientSecret = clientSecret;
  }

  /// (en) Performs sign-in process. Returns false if failed.
  ///
  /// (ja) サインイン処理を行います。失敗したらfalseを返します。
  Future<bool> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse(_authUrl!),
      body: jsonEncode({
        'grant_type': 'password',
        'username': email,
        'password': password,
        'client_id': _clientID,
        'client_secret': _clientSecret,
      }),
    );
    if (response.statusCode == 200) {
      // トークンを取得して保存
      final int nowUnixTimeMS = DateTime.now().millisecondsSinceEpoch;
      final tokens = jsonDecode(response.body);
      _accessToken = tokens['access_token'];
      _accessTokenExpireUnixMS =
          nowUnixTimeMS + (int.parse(tokens['expires_in'].toString()) * 1000);
      _refreshToken = tokens['refresh_token'];
      _refreshTokenExpireUnixMS = nowUnixTimeMS +
          (int.parse(tokens['refresh_expires_in'].toString()) * 1000);
      return true;
    } else {
      return false;
    }
  }

  /// (em)
  ///
  /// (ja) JWTトークンを取得します。
  /// キャッシュされたトークンの期限が残っている場合、キャッシュされたトークンが返されます。
  /// トークンが期限切れの場合はリフレッシュトークンを使ってリフレッシュを試みますが、
  /// 失敗した場合はnullを返します。
  Future<String?> getToken() async {
    // TODO add local mode
    if (_accessToken == null || _isTokenExpired()) {
      await _fetchNewToken();
    }
    return _accessToken;
  }

  /// トークンの期限切れをチェックします。
  bool _isTokenExpired() {
    if (_accessTokenExpireUnixMS == null) return true;
    return DateTime.now().millisecondsSinceEpoch > _accessTokenExpireUnixMS!;
  }

  /// TODO　リフレッシュトークンを使った処理を追加。
  /// 新しいトークンを取得し、キャッシュします。
  Future<void> _fetchNewToken() async {
    // サーバーからトークンを取得
    final response = await http.post(
      Uri.parse(_authUrl!),
      body: {
        'grant_type': 'refresh_token',
      },
    );
  }

  /// 手動でアクセストークン、及びリフレッシュトークンをクリアします。
  void clearToken() {
    _accessToken = null;
    _accessTokenExpireUnixMS = null;
    _refreshToken = null;
    _refreshTokenExpireUnixMS = null;
  }
}
