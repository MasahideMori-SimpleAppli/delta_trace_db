import 'package:file_state_manager/file_state_manager.dart';

import 'enum_dtdb_search_chain_mode.dart';

abstract class DTDBSearchObj extends CloneableFile {
  late final EnumDTDBSearchChainMode chainMode;

  DTDBSearchObj(this.chainMode);
}
