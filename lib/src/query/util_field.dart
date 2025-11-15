/// (en) This is a utility for field access used in internal DB processing.
///
/// (ja) DBの内部処理で利用する、フィールドアクセスに関するユーティリティです。
class UtilField {
  /// (en) Functions for accessing nested fields of a dictionary.
  /// Returns the found value, or None if it doesn't exist.
  ///
  /// (ja) 辞書の、ネストされたフィールドにアクセスするための関数です。
  /// 見つかった値、または存在しなければ null を返します。
  ///
  /// * [map] : A map to explore.
  /// * [path] : A "." separated search path, such as user.name.
  static dynamic getNestedFieldValue(Map<String, dynamic> map, String path) {
    final keys = path.split('.');
    dynamic current = map;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }
}
