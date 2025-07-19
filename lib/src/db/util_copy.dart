class UtilCopy {
  static final int _maxDepth = 100; // 安全な再帰深度上限

  /// (en) Only JSON serializable types will be deep copied.
  /// Throws ArgumentError on unsupported input types.
  /// Note that the return value requires an explicit type conversion.
  /// Also, if you enter data with a depth of 100 or more levels,
  /// an ArgumentError will be thrown.
  ///
  /// (ja) JSONでシリアライズ可能な型のみをディープコピーします。
  /// 戻り値には明示的な型変換が必要であることに注意してください。
  /// 非対応の型を入力するとArgumentErrorをスローします。
  /// また、深さ100階層以上のデータを入力した場合もArgumentErrorをスローします。
  ///
  /// * [value] : The deep copy target.
  /// * [depth] : This is an internal parameter to limit recursive calls.
  /// Do not set this when using from outside.
  static dynamic jsonableDeepCopy(dynamic value, {int depth = 0}) {
    if (depth > _maxDepth) {
      throw ArgumentError('Exceeded max allowed nesting depth ($_maxDepth)');
    }
    // 通常の処理
    if (value is Map<String, dynamic>) {
      return value.map(
        (key, val) => MapEntry(key, jsonableDeepCopy(val, depth: depth + 1)),
      );
    } else if (value is List) {
      return value.map((e) => jsonableDeepCopy(e, depth: depth + 1)).toList();
    } else if (value is String ||
        value is num ||
        value is bool ||
        value == null) {
      return value;
    } else {
      throw ArgumentError(
        'Unsupported type for JSON deep copy: ${value.runtimeType}',
      );
    }
  }
}
