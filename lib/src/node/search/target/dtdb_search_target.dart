import 'package:delta_trace_db/src/node/search/target/enum_dtdb_search_target_type.dart';
import 'package:file_state_manager/file_state_manager.dart';

abstract class DTDBSearchTarget extends CloneableFile{
  
  late final EnumDTDBSearchTargetType targetType;

  DTDBSearchTarget(this.targetType);

}