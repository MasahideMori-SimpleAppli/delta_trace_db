import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) Query node for AND operation.
///
/// (ja) AND演算のためのクエリノード。
class AndNode extends QueryNode {
  final List<QueryNode> conditions;

  /// Query node for AND operation.
  /// * [conditions] : A list of child nodes.
  AndNode(this.conditions);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory AndNode.fromDict(Map<String, dynamic> src) {
    return AndNode(
      (src['conditions'] as List)
          .map((e) => QueryNode.fromDict(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) =>
      conditions.every((c) => c.evaluate(data));

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.and_.name,
    'conditions': conditions.map((c) => c.toDict()).toList(),
    'version': '1',
  };
}

/// (en) Query node for OR operation.
///
/// (ja) OR演算のためのクエリノード。
class OrNode extends QueryNode {
  final List<QueryNode> conditions;

  /// Query node for OR operation.
  /// * [conditions] : A list of child nodes.
  OrNode(this.conditions);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory OrNode.fromDict(Map<String, dynamic> src) {
    return OrNode(
      (src['conditions'] as List)
          .map((e) => QueryNode.fromDict(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) =>
      conditions.any((c) => c.evaluate(data));

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.or_.name,
    'conditions': conditions.map((c) => c.toDict()).toList(),
    'version': '1',
  };
}

/// (en) Query node for NOT operation.
///
/// (ja) NOT演算のためのクエリノード。
class NotNode extends QueryNode {
  final QueryNode condition;

  /// Query node for NOT operation.
  /// * [conditions] : A child node.
  NotNode(this.condition);

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory NotNode.fromDict(Map<String, dynamic> src) {
    return NotNode(
      QueryNode.fromDict(Map<String, dynamic>.from(src['condition'])),
    );
  }

  @override
  bool evaluate(Map<String, dynamic> data) => !condition.evaluate(data);

  @override
  Map<String, dynamic> toDict() => {
    'type': EnumNodeType.not_.name,
    'condition': condition.toDict(),
    'version': '1',
  };
}
