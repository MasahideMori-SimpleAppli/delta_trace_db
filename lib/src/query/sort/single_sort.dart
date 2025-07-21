import 'package:file_state_manager/file_state_manager.dart';
import '../util_filed.dart';
import 'abstract_sort.dart';

/// (en) This class allows you to specify single-key sorting for
/// the return values of a query.
///
/// (ja) クエリの戻り値について、単一キーでのソートを指定するためのクラスです。
class SingleSort extends CloneableFile implements AbstractSort {
  static const String className = "SingleSort";
  static const String version = "2";
  late String field;
  late bool reversed;

  /// (en) This class allows you to specify single-key sorting for
  /// the return values of a query.
  /// When sorting with this class, null values are moved to the back in
  /// ascending sorting and to the front in descending sorting.
  /// Also, boolean values are calculated as 1 for true and 0 for false.
  ///
  /// (ja) クエリの戻り値について、単一キーでのソートを指定するためのクラスです。
  /// このクラスのソートでは、null値は昇順ソートでは後ろに、降順ソートでは前に移動します。
  /// また、bool値はtrueなら1、falseなら0として計算されます。
  /// * [field] : The name of the variable within the class to use for sorting.
  /// * [reversed] : Specifies whether to reverse the sort result.
  SingleSort({required this.field, this.reversed = false});

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  SingleSort.fromDict(Map<String, dynamic> src) {
    field = src["field"];
    reversed = src["reversed"] ?? false;
  }

  @override
  Map<String, dynamic> toDict() {
    return {
      "className": className,
      "version": version,
      "field": field,
      "reversed": reversed,
    };
  }

  @override
  SingleSort clone() {
    return SingleSort.fromDict(toDict());
  }

  @override
  Comparator<Map<String, dynamic>> getComparator() {
    return (Map<String, dynamic> a, Map<String, dynamic> b) {
      final aValue = UtilField.getNestedFieldValue(a, field);
      final bValue = UtilField.getNestedFieldValue(b, field);
      // null値対応用の処理。
      // 両方nullなら同等
      if (aValue == null && bValue == null) return 0;
      // 一方がnullならnullを後に送る（昇順時）
      if (aValue == null) return reversed ? -1 : 1;
      if (bValue == null) return reversed ? 1 : -1;
      int result;
      // boolの場合の処理
      if (aValue is bool && bValue is bool) {
        int aInt = aValue ? 1 : 0;
        int bInt = bValue ? 1 : 0;
        result = aInt.compareTo(bInt);
      }
      // Comparable
      else if (aValue is Comparable && bValue is Comparable) {
        result = aValue.compareTo(bValue);
      } else {
        throw Exception(
          'Field "$field" is not comparable: $aValue (${aValue.runtimeType}), $bValue (${bValue.runtimeType})',
        );
      }
      return reversed ? -result : result;
    };
  }
}
