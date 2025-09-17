import '../../../delta_trace_db.dart';

abstract class AbstractSort {
  /// (en) Comparison function for sorting.
  ///
  /// (ja) ソート用の比較関数です。
  Comparator<Map<String, dynamic>> getComparator();

  /// (en) Convert the object to a dictionary.
  /// The returned dictionary can only contain primitive types, null, lists
  /// or maps with only primitive elements.
  /// If you want to include other classes,
  /// the target class should inherit from this class and chain calls toDict.
  ///
  /// (ja) このオブジェクトを辞書に変換します。
  /// 戻り値の辞書にはプリミティブ型かプリミティブ型要素のみのリスト
  /// またはマップ等、そしてnullのみを含められます。
  /// それ以外のクラスを含めたい場合、対象のクラスもこのクラスを継承し、
  /// toDictを連鎖的に呼び出すようにしてください。
  Map<String, dynamic> toDict();

  /// (en) The appropriate object is automatically detected and restored from
  /// the dictionary.
  ///
  /// (ja) 辞書から適切なオブジェクトを自動判定して復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  static AbstractSort fromDict(Map<String, dynamic> src) {
    switch (src['className']) {
      case SingleSort.className:
        return SingleSort.fromDict(src);
      case MultiSort.className:
        return MultiSort.fromDict(src);
      default:
        throw Exception('Unknown sort class');
    }
  }
}
