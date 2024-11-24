
import 'package:delta_trace_db/src/node/structure/data/dtdb_data.dart';
import 'package:file_state_manager/file_state_manager.dart';
import 'package:collection/collection.dart';

/// (en) A class that represents a single node in a database.
///
/// (ja) データベースの単一のノードを表すクラス。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-03 16:07:11(now creating)
class DTDBNode extends CloneableFile {
  static const String className = "DTDBNode";
  static const int version = 1;

  late final int serial;
  late final int parentSerial;

  // グラフの探索をさせたい時に使う子のシリアルのリスト。
  // つまり、これをソートしたりすることでDBを効率化することは可能。
  late final List<int> children;
  late final String nodeName;
  late final DTDBData data;

  /// * [serial] : The node serial number. The value is 0 or over.
  /// * [parentSerial] : The parent node serial number.
  /// If parent is root, this is -1. If root, this is -2.
  /// * [children] : This is a list of child serial numbers.
  /// The order of the child blocks is as shown in this list.
  /// * [nodeName] : The node name.
  /// * [data] : The node data.
  DTDBNode(
      this.serial, this.parentSerial, this.children, this.nodeName, this.data);

  factory DTDBNode.fromDict(Map<String, dynamic> src) {
    return DTDBNode(src["serial"], src["parentSerial"], src["children"],
        src["nodeName"], DTDBData.fromDict(src["data"]));
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "serial": serial,
      "parentSerial": parentSerial,
      "children": children,
      "nodeName": nodeName,
      "data": data.toDict()
    };
  }

  @override
  DTDBNode clone() {
    return DTDBNode.fromDict(toDict());
  }

  @override
  bool operator ==(Object other) {
    if (other is DTDBNode) {
      return nodeName == other.nodeName &&
          parentSerial == other.parentSerial &&
          const ListEquality().equals(children, other.children) &&
          nodeName == other.nodeName &&
          data == other.data;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll([serial, parentSerial, children, nodeName, data]);
  }
}
