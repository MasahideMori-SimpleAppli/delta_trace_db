import 'package:delta_trace_db/src/node/search/function/dtdb_search_function.dart';
import 'package:delta_trace_db/src/node/search/function/enum_dtdb_search_function_type.dart';

/// (en) An object used for condition determination when searching a database.
/// Used for comparing numbers.
///
/// (ja) データベースを探索する際に利用される、条件判定用オブジェクト。
/// 数値の比較で使用します。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-03 18:32:33
class DTDBSearchFunctionInRange extends DTDBSearchFunction {
  static const String className = "DTDBSearchFunctionInRange";
  static const int version = 1;
  late final double? min;
  late final double? max;

  DTDBSearchFunctionInRange(this.min, this.max)
      : super(EnumDTDBSearchFunctionType.fcInRange);

  factory DTDBSearchFunctionInRange.fromDict(Map<String, dynamic> src) {
    return DTDBSearchFunctionInRange(src["min"], src["max"]);
  }

  @override
  Map<String, dynamic> toDict() {
    return {"className": className, "version": version, "min": min, "max": max};
  }

  @override
  DTDBSearchFunctionInRange clone() {
    return DTDBSearchFunctionInRange.fromDict(toDict());
  }
}
