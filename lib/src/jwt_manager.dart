import 'dart:convert';

import 'package:http/http.dart' as http;

/// (en) A class for managing JWT tokens.
/// You can extend this class to provide your own authentication method.
///
/// (ja) JWTトークンの管理用クラスです。
/// このクラスを拡張して使用することで、独自の認証方法に置き換えることが可能です。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-10-27 17:51:00(now creating)
class JWTManager {

  // parameters
  late final String? _authUrl;
  late final String _email;
  late final String _password;
  bool get isRemote => _authUrl != null;
  String? _accessToken;
  DateTime? _expiryTime;

  // methods
  /// (en) This is an initialization function. If the endpoint URL is not null,
  /// it will be configured to access the specified server.
  ///
  /// (ja) 初期化関数です。エンドポイントURLがnullではない場合、
  /// 指定サーバーに対してアクセスを行うように構成されます。
  ///
  /// * [endpointUrl] : The authentication URL.
  /// If null, this class will be initialized for local mode.
  JWTManager({required String? endpointUrl, required String email, required String password}) {
    _authUrl = endpointUrl;
    _email = email;
    _password = password;
  }

  /// JWTトークンを取得します。
  /// キャッシュされたトークンの期限が残っている場合、キャッシュされたトークンが返されます。
  Future<String> getToken() async {
    // TODO add local mode
    if (_accessToken == null || _isTokenExpired()) {
      await _fetchNewToken();
    }
    return _accessToken!;
  }

  /// トークンの期限切れをチェックします。
  bool _isTokenExpired() {
    if (_expiryTime == null) return true;
    return DateTime.now().isAfter(_expiryTime!);
  }

  /// 新しいトークンを取得し、キャッシュします。
  Future<void> _fetchNewToken() async {
    // サーバーからトークンを取得
    final response = await http.post(
      // TODO Local mode
      Uri.parse(_authUrl!),
      body: {
        'grant_type': 'password',
        'username': _email,
        'password': _password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      final expiresIn = data['expires_in'];
      // TODO 恐らく、利用の観点から数分〜１時間程度の余裕を設定できるようにした方が良い。
      // TODO これはデータアクセス中に期限切れになるのを防ぐため。
      _expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    } else {
      throw Exception("Failed to fetch JWT token");
    }
  }

  // 手動でトークンをクリア
  void clearToken() {
    _accessToken = null;
    _expiryTime = null;
  }
}
