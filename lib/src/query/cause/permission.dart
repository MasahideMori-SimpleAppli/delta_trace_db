import 'package:collection/collection.dart';
import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:file_state_manager/file_state_manager.dart';

/// (en) This class deals with database permissions.
///
/// (ja) データベースのパーミッションに関するクラスです。
class Permission extends CloneableFile {
  static const String className = "Permission";
  static const String version = "1";

  List<EnumQueryType> allows;

  /// * [allows] : It is invalid when it is null.
  /// Only calls of the specified type are allowed.
  /// If you attempt to process a query of a type not specified here,
  /// the QueryResult will return false.
  Permission(this.allows);

  /// (en) Recover this class from the dictionary.
  ///
  /// (ja) 辞書からこのクラスを復元します。
  factory Permission.fromDict(Map<String, dynamic> src) {
    List<EnumQueryType> allows = [];
    List<String> mAllows = (src["allows"] as List).cast<String>();
    for (String i in mAllows) {
      allows.add(EnumQueryType.values.byName(i));
    }
    return Permission(allows);
  }

  @override
  Permission clone() {
    return Permission.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    List<String>? mAllows = [];
    for (EnumQueryType i in allows) {
      mAllows.add(i.name);
    }
    return {"className": className, "version": version, "allows": mAllows};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission &&
        const ListEquality<EnumQueryType>().equals(allows, other.allows);
  }

  @override
  int get hashCode => Object.hashAll([UtilObjectHash.calcList(allows)]);
}
