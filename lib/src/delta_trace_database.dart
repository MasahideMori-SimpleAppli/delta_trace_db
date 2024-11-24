import 'dart:async';
import 'package:delta_trace_db/src/delta/dtdb_delta.dart';

import 'package:delta_trace_db/src/local/dtdb_core.dart';
import 'package:simple_jwt_manager/simple_jwt_manager.dart';

import 'local/enum_dtdb_user_type.dart';

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
  /// * [endpointUrl] : The URL of the database implemented as an https server.
  /// If null, it will operate in local mode.
  /// * [timeout] : Timeout period for server access.
  Future<void> initialize({String? endpointUrl, Duration? timeout}) async {
    _endpointUrl =
        endpointUrl != null ? UtilCheckURL.validateHttpsUrl(endpointUrl) : null;
    _timeout = timeout ?? const Duration(minutes: 1);
    if (isLocalMode) {
      // ローカルデータベースのセットアップ
      _dbCore = DTDBCore();
    }
  }

  /// Databaseに対して操作を行います。
  /// * [jwt] : ユーザー認証用のJWTトークン。ローカルモードでは利用されず、かつ検証済みである必要があります。
  /// * [localModeSID] : ローカルモードで使用する、既に認証されたユーザーのSID。
  /// * [userType] : ローカルモードで使用する、アクセス元がユーザーなのかシステムなのかの指定。
  /// システムによるアクセスの場合のみ、システムレイヤへのアクセスが許可されます。
  Future<ServerResponse> operate(DTDBDelta delta,
      {String? jwt,
      String localModeSID = "local_user",
      EnumDTDBUserType userType = EnumDTDBUserType.general}) {
    if (isLocalMode) {
      return _dbCore!
          .operate([delta], localModeSID: localModeSID, userType: userType);
    } else {
      return _sendToServer(_endpointUrl!, jwt, [delta]);
    }
  }

  /// Databaseに対して複数の操作を行います。
  /// * [jwt] : ユーザー認証用のJWTトークン。ローカルモードでは利用されず、かつ検証済みである必要があります。
  /// * [localModeSID] : ローカルモードで使用する、既に認証されたユーザーのSID。
  /// * [userType] : ローカルモードで使用する、アクセス元がユーザーなのかシステムなのかの指定。
  /// システムによるアクセスの場合のみ、システムレイヤへのアクセスが許可されます。
  Future<ServerResponse> multiOperate(List<DTDBDelta> deltaList,
      {String? jwt,
      String localModeSID = "local_user",
      EnumDTDBUserType userType = EnumDTDBUserType.general}) {
    if (isLocalMode) {
      return _dbCore!
          .operate(deltaList, localModeSID: localModeSID, userType: userType);
    } else {
      return _sendToServer(_endpointUrl!, jwt, deltaList);
    }
  }

  /// Databaseと同様のスキームで処理を行う、特定のエンドポイントに対して操作を行います。
  /// これはネットワークが必須のため、ローカルモードでは動作しません。
  /// * [endpointUrl] : DeltaTraceDatabaseと同様のスキームで処理を行えるエンドポイントのURL。
  /// これを用いると、検索結果に追加の独自処理を加えたい場合などに、クラウド関数を挟んで処理できます。
  /// * [jwt] : ユーザー認証用のJWTトークン。ローカルモードでは利用されず、かつ検証済みである必要があります。
  Future<ServerResponse> operateTo(
      String endpointUrl, String? jwt, DTDBDelta delta) {
    return _sendToServer(endpointUrl, jwt, [delta]);
  }

  /// Databaseと同様のスキームで処理を行う、特定のエンドポイントに対して複数の操作を行います。
  /// これはネットワークが必須のため、ローカルモードでは動作しません。
  /// * [endpointUrl] : DeltaTraceDatabaseと同様のスキームで処理を行えるエンドポイントのURL。
  /// これを用いると、検索結果に追加の独自処理を加えたい場合などに、クラウド関数を挟んで処理できます。
  /// * [jwt] : ユーザー認証用のJWTトークン。ローカルモードでは利用されず、かつ検証済みである必要があります。
  Future<ServerResponse> multiOperateTo(
      String endpointUrl, String? jwt, List<DTDBDelta> deltaList) {
    return _sendToServer(endpointUrl, jwt, deltaList);
  }

  /// サーバーにデータをPOSTします。
  /// * [jwt] : ユーザー認証用のJWTトークン。ローカルモードでは利用されず、かつ検証済みである必要があります。
  Future<ServerResponse> _sendToServer(
      String endpointUrl, String? jwt, List<DTDBDelta> deltaList) async {
    List<Map<String, dynamic>> mDeltaList = [];
    for (DTDBDelta i in deltaList) {
      mDeltaList.add(i.toDict());
    }
    return UtilHttps.post(
        endpointUrl, {"deltaList": mDeltaList}, EnumPostEncodeType.json,
        jwt: jwt, timeout: _timeout);
  }
}
