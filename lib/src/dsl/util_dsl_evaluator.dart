import 'package:delta_trace_db/delta_trace_db.dart';
import 'package:delta_trace_db/src/query/util_field.dart';

/// (en) Internal object for handling the results of decomposing references
/// such as base.xxx and 0.xxx
///
/// (ja) base.xxx や 0.xxx のような参照を分解した結果を扱うための内部オブジェクト
class _DSLObj {
  final String target; // "base" or "0", "1" ...
  final String? keyPath; // "aaa.bbb" のような "1 つの文字列"、またはnull。
  _DSLObj(this.target, this.keyPath);

  /// Constructor that resolves a reference of the form N.xxx to a target
  /// and keyPath and saves it.
  /// * [s] : Source text. e.g. base.aaa, 0.bbb.ccc.
  factory _DSLObj.fromStr(String s) {
    if (s.isEmpty) {
      throw FormatException('Empty DSL path');
    }
    final dot = s.indexOf('.');
    if (dot == -1) {
      return _DSLObj(s, null);
    }
    if (dot == 0 || dot == s.length - 1) {
      throw FormatException('Invalid DSL path');
    }
    return _DSLObj(s.substring(0, dot), s.substring(dot + 1));
  }
}

/// (en) A utility for evaluating DSL.
///
/// (ja) DSLの評価用ユーティリティです。
class UtilDslEvaluator {
  /// (en) It interprets templates written in DSL and merges collection data
  /// according to the template.
  ///
  /// (ja) DSLで書かれたテンプレートを解釈し、
  /// コレクションのデータをテンプレートに沿ってマージします。
  ///
  /// * [template] : This varies depending on the internal recursion,
  /// and the Map or List format is passed in.
  /// The first call passes MergeQueryParams.dslTmp.
  /// * [base] : A base collection item.
  /// * [source] : A list of related items retrieved from each related collection.
  /// The index matches the MergeQueryParams.source.
  static dynamic run(
    dynamic template,
    Map<String, dynamic> base,
    List<Map<String, dynamic>> source,
  ) {
    // Map → 各 value を評価
    if (template is Map<String, dynamic>) {
      final Map<String, dynamic> result = {};
      for (final entry in template.entries) {
        result[entry.key] = run(entry.value, base, source);
      }
      return result;
    }
    // List → 各要素を評価
    if (template is List) {
      return template.map((e) => run(e, base, source)).toList();
    }
    // String → DSL として評価
    if (template is String) {
      return parse(template, base, source);
    }
    // その他はそのまま
    return template;
  }

  /// (en) Interprets the DSL and transforms the data.
  /// This is used internally and should not normally be called externally.
  ///
  /// (ja) DSLを解釈してデータを変換します。
  /// これは内部的に使用されるため、通常は外部から呼び出さないでください。
  ///
  /// * [dsl] : A dsl code.
  /// * [base] : A base collection item.
  /// * [source] : A list of related items retrieved from each related collection.
  /// The index matches the MergeQueryParams.source.
  static dynamic parse(
    String dsl,
    Map<String, dynamic> base,
    List<Map<String, dynamic>> source,
  ) {
    dsl = dsl.trim();

    // none
    if (dsl == "none" || dsl == "null") return null;

    // int(n)
    if (dsl.startsWith('int(') && dsl.endsWith(')')) {
      return int.parse(dsl.substring(4, dsl.length - 1));
    }

    // float(n)
    if (dsl.startsWith('float(') && dsl.endsWith(')')) {
      return double.parse(dsl.substring(6, dsl.length - 1));
    }

    // bool(x)
    if (dsl.startsWith('bool(') && dsl.endsWith(')')) {
      final v = dsl.substring(5, dsl.length - 1);
      if (v == 'true') return true;
      if (v == 'false') return false;
      throw FormatException('Invalid bool literal');
    }

    // str(xxx)
    if (dsl.startsWith('str(') && dsl.endsWith(')')) {
      return dsl.substring(4, dsl.length - 1);
    }

    // [N] or [N.xxx] → 配列化
    if (dsl.startsWith('[') && dsl.endsWith(']')) {
      final inner = dsl.substring(1, dsl.length - 1);
      // 再帰評価
      final value = UtilCopy.jsonableDeepCopy(parse(inner, base, source));
      return [value];
    }

    // popped.N[a.b,c.d]。popped.N[]のように空ならマッチさせない。
    if (dsl.startsWith('popped.') && dsl.endsWith(']')) {
      final body = dsl.substring(7, dsl.length - 1); // N[a.b,c.d
      final bracket = body.indexOf('[');
      if (bracket == -1) throw FormatException('Invalid DSL path');
      final targetPart = body.substring(0, bracket);
      final pathsPart = body.substring(bracket + 1);
      final Map<String, dynamic> r = UtilCopy.jsonableDeepCopy(
        _getTargetCollection(targetPart, base, source),
      );
      for (final raw in pathsPart.split(',')) {
        final path = raw.trim();
        if (path.isEmpty) continue;
        _removeByDotPath(r, path);
      }
      return r;
    }

    // N or N.xxx
    final dslObj = _DSLObj.fromStr(dsl);
    final target = _getTargetCollection(dslObj.target, base, source);
    if (dslObj.keyPath == null) {
      return UtilCopy.jsonableDeepCopy(target);
    } else {
      return UtilCopy.jsonableDeepCopy(
        UtilField.getNestedFieldValue(target, dslObj.keyPath!),
      );
    }
  }

  /// DSLのターゲットとして指定されたコレクションを取得します。
  static Map<String, dynamic> _getTargetCollection(
    String target,
    Map<String, dynamic> base,
    List<Map<String, dynamic>> source,
  ) {
    if (target == "base") {
      return base;
    } else {
      final int index = int.parse(target);
      return source[index];
    }
  }

  /// ドット記法で、指定された要素を削除します。
  static void _removeByDotPath(Map<String, dynamic> root, String path) {
    final parts = path.split('.');
    if (parts.isEmpty) return;
    Map<String, dynamic>? current = root;
    for (int i = 0; i < parts.length - 1; i++) {
      final key = parts[i];
      final next = current?[key];
      if (next is Map<String, dynamic>) {
        current = next;
      } else {
        // 途中で辿れない → 何もしない
        return;
      }
    }
    current?.remove(parts.last);
  }

  /// (en) Interprets the relation to get the list of items to merge.
  ///
  /// (ja) リレーションを解釈してマージ対象のアイテムのリストを取得します。
  ///
  /// * [baseItem] : The merge base item.
  /// * [sourceCollections] : The merge target collections.
  /// * [relationKey] : Merge relation key of base item.
  /// * [sourceKeys] : Merge relation keys of sourceCollections.
  static List<Map<String, dynamic>> resolveSourceItems(
    Map<String, dynamic> baseItem,
    List<List<Map<String, dynamic>>> sourceCollections,
    String relationKey,
    List<String> sourceKeys,
  ) {
    final List<Map<String, dynamic>> result = [];
    for (int i = 0; i < sourceCollections.length; i++) {
      final sourceKey = sourceKeys[i];
      final baseValue = baseItem[relationKey];
      Map<String, dynamic>? hit;
      if (baseValue != null) {
        for (final item in sourceCollections[i]) {
          if (item[sourceKey] == baseValue) {
            hit = item;
            break;
          }
        }
      }
      // 見つからなくても index を揃える
      result.add(hit ?? <String, dynamic>{});
    }
    return result;
  }
}
