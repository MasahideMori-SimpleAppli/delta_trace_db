import 'package:file_state_manager/file_state_manager.dart';
import '../util_filed.dart';
import 'abstract_sort.dart';

/// (en) This class allows you to specify single-key sorting for
/// the return values of a query.
///
/// (ja) クエリの戻り値について、単一キーでのソートを指定するためのクラスです。
class SingleSort extends CloneableFile implements AbstractSort {
  static const String className = "SingleSort";
  static const String version = "1";
  late String field;
  late bool reversed;

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
      if (aValue is Comparable && bValue is Comparable) {
        return reversed ? bValue.compareTo(aValue) : aValue.compareTo(bValue);
      }
      throw Exception('Field "$field" is not Comparable: $aValue, $bValue');
    };
  }
}
