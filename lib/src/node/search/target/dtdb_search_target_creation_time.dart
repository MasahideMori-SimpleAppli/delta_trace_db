import 'package:delta_trace_db/src/node/search/target/dtdb_search_target.dart';
import 'package:delta_trace_db/src/node/search/target/enum_dtdb_search_target_type.dart';

import '../function/dtdb_search_function_in_int_range.dart';

class DTDBSearchTargetCreationTime extends DTDBSearchTarget {
  late final DTDBSearchFunctionInIntRange searchFunction;

  DTDBSearchTargetCreationTime(this.searchFunction)
      : super(EnumDTDBSearchTargetType.creationTimeMS);

  factory DTDBSearchTargetCreationTime.fromDict(Map<String, dynamic> src) {
    return DTDBSearchTargetCreationTime(
        DTDBSearchFunctionInIntRange.fromDict(src["searchFunction"]));
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }

  @override
  DTDBSearchTargetCreationTime clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }


}
