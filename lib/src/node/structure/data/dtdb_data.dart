import 'package:collection/collection.dart';
import 'package:file_state_manager/file_state_manager.dart';

/// (en)This is a data class stored in a database node.
/// In addition to user data, it also holds information
/// such as the data creation date.
///
/// (ja)データベースのノードに格納されるデータクラスです。
/// ユーザー用のデータの他に、データ作成日などの情報も保持されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:52:11(now creating)
class DTDBData extends CloneableFile {
  static const String className = "DTDBData";
  static const int version = 1;

  // データの内容。操作がupdateの場合は更新部分のデータのみが含まれます。
  late Map<String, dynamic> data;

  // UNIXTime
  // このデータの作成日時。サーバー側での処理時の時刻が入ります。
  int? creationTimeMS;

  // このデータの更新日時。サーバー側での処理時の時刻が入ります。
  // 初期状態ではcreationTimeMSと同じ値です。
  int? updateTimeMS;

  /// * [data] : データの内容。
  DTDBData(this.data, {this.creationTimeMS, this.updateTimeMS});

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory DTDBData.fromDict(Map<String, dynamic> src) {
    return DTDBData(src["data"],
        creationTimeMS: src["creationTimeMS"],
        updateTimeMS: src["updateTimeMS"]);
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "data": data,
      "creationTimeMS": creationTimeMS,
      "updateTimeMS": updateTimeMS,
    };
  }

  @override
  DTDBData clone() {
    return DTDBData.fromDict(toDict());
  }

  @override
  bool operator ==(Object other) {
    if (other is DTDBData) {
      return const MapEquality().equals(data, other.data) &&
          creationTimeMS == other.creationTimeMS &&
          updateTimeMS == other.updateTimeMS;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll(
        [UtilObjectHash.calcMap(data), creationTimeMS, updateTimeMS]);
  }
}
