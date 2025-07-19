import '../../../delta_trace_db.dart';

abstract class QueryNode {
  /// (en) Returns true if the object matches the calculation.
  ///
  /// (ja) 計算と一致するオブジェクトだった場合はtrueを返します。
  bool evaluate(Map<String, dynamic> data);

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

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  static QueryNode fromDict(Map<String, dynamic> src) {
    final EnumNodeType nodeType = EnumNodeType.values.byName(src['type']);
    switch (nodeType) {
      case EnumNodeType.and_:
        return AndNode.fromDict(src);
      case EnumNodeType.or_:
        return OrNode.fromDict(src);
      case EnumNodeType.not_:
        return NotNode.fromDict(src);
      case EnumNodeType.equals_:
        return FieldEquals.fromDict(src);
      case EnumNodeType.notEquals_:
        return FieldNotEquals.fromDict(src);
      case EnumNodeType.greaterThan_:
        return FieldGreaterThan.fromDict(src);
      case EnumNodeType.lessThan_:
        return FieldLessThan.fromDict(src);
      case EnumNodeType.greaterThanOrEqual_:
        return FieldGreaterThanOrEqual.fromDict(src);
      case EnumNodeType.lessThanOrEqual_:
        return FieldLessThanOrEqual.fromDict(src);
      case EnumNodeType.regex_:
        return FieldMatchesRegex.fromDict(src);
      case EnumNodeType.contains_:
        return FieldContains.fromDict(src);
      case EnumNodeType.in_:
        return FieldIn.fromDict(src);
      case EnumNodeType.notIn_:
        return FieldNotIn.fromDict(src);
      case EnumNodeType.startsWith_:
        return FieldStartsWith.fromDict(src);
      case EnumNodeType.endsWith_:
        return FieldEndsWith.fromDict(src);
    }
  }
}
