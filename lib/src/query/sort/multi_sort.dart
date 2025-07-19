import '../../../delta_trace_db.dart';

/// (en) A class for specifying multi-dimensional sorting of
/// query return values.
///
/// (ja) クエリの戻り値について、多次元ソートを指定するためのクラスです。
class MultiSort implements AbstractSort {
  static const String className = "MultiSort";
  static const String version = "1";

  final List<SingleSort> sortOrders;

  /// * [sortOrders] : A list of sort specifications for individual keys.
  /// The sorts are applied in the order listed.
  MultiSort(this.sortOrders);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  static MultiSort fromDict(Map<String, dynamic> src) {
    final orders = (src['sortOrders'] as List)
        .map((e) => SingleSort.fromDict(e as Map<String, dynamic>))
        .toList();
    return MultiSort(orders);
  }

  @override
  Comparator<Map<String, dynamic>> getComparator() {
    return (Map<String, dynamic> a, Map<String, dynamic> b) {
      for (final sortObj in sortOrders) {
        final comp = sortObj.getComparator()(a, b);
        if (comp != 0) return comp;
      }
      return 0;
    };
  }

  @override
  Map<String, dynamic> toDict() => {
    'className': className,
    'version': version,
    'sortOrders': sortOrders.map((s) => s.toDict()).toList(),
  };
}
