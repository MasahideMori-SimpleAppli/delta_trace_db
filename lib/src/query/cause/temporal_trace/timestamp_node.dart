import 'package:file_state_manager/file_state_manager.dart';

import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) A node representing each checkpoint on the trajectory.
/// This will contain individual data for each point,
/// in case data needs to be relayed between servers, etc.
///
/// (ja) 軌跡上の各チェックポイントを表すノードです。
/// サーバー間でデータのリレーが必要になった場合などには、各地点での個別のデータが入ります。
class TimestampNode extends CloneableFile {
  static const String className = "TimestampNode";
  static const String version = "1";

  // データが生成された地点で記録されたタイムスタンプ
  final DateTime timestamp;

  // データが生成された地点の名称や識別子
  // 例: 'UserBrowserClient', 'ApiGateway', 'MarsRelaySatellite-7'
  final String location;

  // データが生成された地点での追加コンテキスト情報。キーはロケーション名。
  final Map<String, dynamic> context;

  /// * [timestamp] : The timestamp recorded when the data was generated.
  /// * [location] : The name or identifier of the location where the data
  /// was generated.
  /// e.g. 'UserBrowserClient', 'ApiGateway', 'MarsRelaySatellite-7'
  /// * [context] : Additional contextual information about where the data was
  /// generated. The key is the location name.
  TimestampNode({
    required this.timestamp,
    required this.location,
    this.context = const {},
  });

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory TimestampNode.fromDict(Map<String, dynamic> src) {
    return TimestampNode(
      timestamp: DateTime.parse(src["timestamp"]),
      location: src["location"],
      context: src["context"] as Map<String, dynamic>,
    );
  }

  @override
  TimestampNode clone() {
    return TimestampNode.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "timestamp": timestamp.toUtc().toIso8601String(),
      "location": location,
      "context": UtilCopy.jsonableDeepCopy(context),
    };
  }
}
