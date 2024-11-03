import 'package:delta_trace_db/src/node/search/function/enum_dtdb_search_function_type.dart';
import 'package:file_state_manager/file_state_manager.dart';

abstract class DTDBSearchFunction extends CloneableFile{
  late final EnumDTDBSearchFunctionType functionType;

  DTDBSearchFunction(this.functionType);
}