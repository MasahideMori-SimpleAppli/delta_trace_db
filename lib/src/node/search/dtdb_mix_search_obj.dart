import 'package:file_state_manager/file_state_manager.dart';

import 'dtdb_search_obj.dart';
import 'enum_dtdb_search_chain_mode.dart';

/// 複数パラメータで探索する場合に利用するオブジェクト。
/// 探索条件にカッコの計算が必要になる場合に使用します。
class DTDBMixSearchObj extends CloneableFile {
  late final List<DTDBSearchObj> objs;
  late final EnumDTDBSearchChainMode calcMode;

  DTDBMixSearchObj(this.objs, this.calcMode);

  factory DTDBMixSearchObj.fromDict(Map<String, dynamic> src) {
    List<DTDBSearchObj> mObjs = [];
    for (Map<String, dynamic> i in src["targets"]) {
      mObjs.add(DTDBSearchObj.fromDict(i));
    }
    return DTDBMixSearchObj(
        mObjs, EnumDTDBSearchChainMode.values.byName(src["calcMode"]));
  }

  @override
  Map<String, dynamic> toDict() {
    List<Map<String, dynamic>> mTargets = [];
    for (DTDBSearchObj i in objs) {
      mTargets.add(i.toDict());
    }
    return {"objs": mTargets, "calcMode": calcMode.name};
  }

  @override
  DTDBMixSearchObj clone() {
    return DTDBMixSearchObj.fromDict(toDict());
  }
}
