import 'package:delta_trace_db/src/node/search/function/dtdb_search_function.dart';
import 'package:delta_trace_db/src/node/search/function/enum_dtdb_search_function_type.dart';

/// (en) An object used for condition determination when searching a database.
/// It is mainly used for comparing date and time ranges.
///
/// (ja) データベースを探索する際に利用される、条件判定用オブジェクト。
/// 主に日時の範囲比較で使用します。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-03 18:32:33
class DTDBSearchFunctionInIntRange extends DTDBSearchFunction {
  static const String className = "DTDBSearchFunctionInIntRange";
  static const int version = 1;
  late final int? min;
  late final int? max;

  DTDBSearchFunctionInIntRange(this.min, this.max)
      : super(EnumDTDBSearchFunctionType.fcInIntRange);

  factory DTDBSearchFunctionInIntRange.fromDict(Map<String, dynamic> src) {
    return DTDBSearchFunctionInIntRange(src["min"], src["max"]);
  }

  @override
  Map<String, dynamic> toDict() {
    return {"className": className, "version": version, "min": min, "max": max};
  }

  @override
  DTDBSearchFunctionInIntRange clone() {
    return DTDBSearchFunctionInIntRange.fromDict(toDict());
  }
}
