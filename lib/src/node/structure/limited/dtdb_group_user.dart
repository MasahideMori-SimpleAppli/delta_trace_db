import 'package:delta_trace_db/src/node/structure/limited/enum_dtdb_limited_authority.dart';
import 'package:file_state_manager/file_state_manager.dart';

class DTDBGroupUser extends CloneableFile{
  final String uid;
  final EnumDTDBLimitedAuthority authority;

  DTDBGroupUser(this.uid, this.authority);

  @override
  CloneableFile clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toDict() {
    // TODO: implement toDict
    throw UnimplementedError();
  }
}
