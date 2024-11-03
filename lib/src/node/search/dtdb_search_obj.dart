import 'package:delta_trace_db/src/node/search/enum_dtdb_search_chain_mode.dart';
import 'package:delta_trace_db/src/node/search/target/dtdb_search_target.dart';
import 'package:delta_trace_db/src/node/search/target/dtdb_search_target_creation_time.dart';
import 'package:delta_trace_db/src/node/search/target/enum_dtdb_search_target_type.dart';
import 'package:file_state_manager/file_state_manager.dart';

/// (en) Class used when searching for database nodes.
/// Data search is performed according to the conditions specified in this class.
///
/// (ja) データベースのノードを探索する時に利用するクラス。
/// このクラスで指定した条件に従ってデータの探索が実行されます。
///
/// Author Masahide Mori
///
/// First edition creation date 2024-11-02 16:05:26(now creating)
class DTDBSearchObj extends CloneableFile{

  late final DTDBSearchTarget target;
  late final EnumDTDBSearchChainMode calcMode;

  DTDBSearchObj(this.target, this.calcMode);

  factory DTDBSearchObj.fromDict(Map<String, dynamic> src) {
    late DTDBSearchTarget mTarget;
    EnumDTDBSearchTargetType targetType = src["target"]["targetType"];
    switch(targetType){
      case EnumDTDBSearchTargetType.nodeName:
        // TODO: Handle this case.
        break;
      case EnumDTDBSearchTargetType.data:
        // TODO: Handle this case.
        break;
      case EnumDTDBSearchTargetType.creationTimeMS:
        mTarget = DTDBSearchTargetCreationTime.fromDict(src["target"]);
        break;
      case EnumDTDBSearchTargetType.updateTimeMS:
        // TODO: Handle this case.
        break;
    }
    return DTDBSearchObj(mTarget, EnumDTDBSearchChainMode.values.byName(src["calcMode"]));
  }

  @override
  Map<String, dynamic> toDict() {
    return {"target": target.toDict(), "calcMode": calcMode.name};
  }

  @override
  DTDBSearchObj clone() {
    return DTDBSearchObj.fromDict(toDict());
  }

}