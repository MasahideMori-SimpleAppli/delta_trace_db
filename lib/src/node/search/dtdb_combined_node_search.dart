import 'package:delta_trace_db/src/node/search/dtdb_search_obj.dart';
import 'dtdb_node_search.dart';
import 'enum_dtdb_search_chain_mode.dart';

/// 複数パラメータで探索する場合に利用するオブジェクト。
/// 探索条件にカッコの計算が必要になる複合検索などに使用します。
class DTDBCombinedNodeSearch extends DTDBSearchObj {
  late final List<DTDBNodeSearch> objs;

  DTDBCombinedNodeSearch(this.objs, super.chainMode);

  factory DTDBCombinedNodeSearch.fromDict(Map<String, dynamic> src) {
    List<DTDBNodeSearch> mObjs = [];
    for (Map<String, dynamic> i in src["targets"]) {
      mObjs.add(DTDBNodeSearch.fromDict(i));
    }
    return DTDBCombinedNodeSearch(
        mObjs, EnumDTDBSearchChainMode.values.byName(src["chainMode"]));
  }

  @override
  Map<String, dynamic> toDict() {
    List<Map<String, dynamic>> mTargets = [];
    for (DTDBNodeSearch i in objs) {
      mTargets.add(i.toDict());
    }
    return {"objs": mTargets, "chainMode": chainMode.name};
  }

  @override
  DTDBCombinedNodeSearch clone() {
    return DTDBCombinedNodeSearch.fromDict(toDict());
  }
}
