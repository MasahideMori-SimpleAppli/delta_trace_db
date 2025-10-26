import 'package:file_state_manager/file_state_manager.dart';

import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) This class records the "time trail" of an event.
/// This allows you to track transmissions,
/// even when communication paths are relayed.
/// This can be used in the future to communicate between planets, etc.
///
/// (ja) イベントの「時間の軌跡」を記録するクラスです。
/// これを利用することで、通信経路をリレーする場合も含め、転送を追跡できます。
/// これは将来的に惑星間通信などが必要になってもそのまま利用できるようになっています。
class TemporalTrace extends CloneableFile {
  static const String className = "TemporalTrace";
  static const String version = "1";

  // タイムスタンプの連鎖（チェーン）。経路順でタイムスタンプが格納されます。
  final List<TimestampNode> nodes;

  /// * [nodes] : A chain of timestamps, which stores timestamps in route order.
  TemporalTrace({this.nodes = const []});

  /// (en) The time when the first event occurred.
  /// Usually returns the time when the data was sent on the frontend device.
  ///
  /// (ja) 最初のイベントが発生した時刻です。
  /// 通常はフロントエンドデバイスにおけるデータ送信時の時刻を返します。
  DateTime? get initiatedAt => nodes.isNotEmpty ? nodes.first.timestamp : null;

  /// (en) The time when the last event was recorded.
  /// Usually returns the time when it reached the endpoint server.
  ///
  /// (ja) 最後のイベントが記録された時刻です。
  /// 通常はエンドポイントサーバー到達時点の時刻を返します。
  DateTime? get finalizedAt => nodes.isNotEmpty ? nodes.last.timestamp : null;

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory TemporalTrace.fromDict(Map<String, dynamic> src) {
    final List<TimestampNode> mNodes = [];
    List<Map<String, dynamic>> nodesMap = (src["nodes"] as List)
        .cast<Map<String, dynamic>>();
    for (Map<String, dynamic> node in nodesMap) {
      mNodes.add(TimestampNode.fromDict(node));
    }
    return TemporalTrace(nodes: mNodes);
  }

  @override
  TemporalTrace clone() {
    return TemporalTrace.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    final List<Map<String, dynamic>> mNodes = [];
    for (TimestampNode node in nodes) {
      mNodes.add(node.toDict());
    }
    return {"className": className, "version": version, "nodes": mNodes};
  }
}
