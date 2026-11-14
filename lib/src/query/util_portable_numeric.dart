import 'package:delta_trace_db/delta_trace_db.dart';

/// (en) Utilities for EnumValueType.decimal_ and EnumValueType.rational_.
/// Only String and the simple_portable_numeric types are converted.
/// Numbers such as int and double are rejected, because their exactness cannot
/// be guaranteed (e.g. int is a double on the web, and the string form of
/// double differs between Dart and Python).
///
/// (ja) EnumValueType.decimal_ と EnumValueType.rational_ 用のユーティリティです。
/// 変換対象は String と simple_portable_numeric の型のみです。
/// int や double などの数値型は、正確さを保証できないため変換しません
/// （例：Webではintもdoubleであり、doubleの文字列表現はDartとPythonで異なります）。
class UtilPortableNumeric {
  /// (en) Converts a value to PortableDecimal or PortableRational
  /// according to [vType].
  ///
  /// (ja) [vType] に従って、値を PortableDecimal または PortableRational に
  /// 変換します。
  ///
  /// * [value] : The conversion target.
  /// * [vType] : EnumValueType.decimal_ or EnumValueType.rational_.
  ///
  /// Throws [FormatException] if the value cannot be converted.
  static Comparable<dynamic> convert(Object? value, EnumValueType vType) {
    switch (vType) {
      case EnumValueType.decimal_:
        if (value is PortableDecimal) return value;
        if (value is String) return PortableDecimal.parse(value);
        break;
      case EnumValueType.rational_:
        if (value is PortableRational) return value;
        if (value is PortableDecimal) return value.toRational();
        if (value is String) return PortableRational.parse(value);
        break;
      default:
        throw ArgumentError.value(
          vType,
          "vType",
          "must be decimal_ or rational_",
        );
    }
    throw FormatException("Cannot convert value to ${vType.name}", value);
  }

  /// (en) Converts both values with [vType] and compares them by value.
  ///
  /// (ja) 両方の値を [vType] で変換し、値で比較します。
  ///
  /// * [a] : The left value.
  /// * [b] : The right value.
  /// * [vType] : EnumValueType.decimal_ or EnumValueType.rational_.
  ///
  /// Returns -1 if a < b, 0 if equal, 1 if a > b.
  /// Throws [FormatException] if either value cannot be converted.
  static int compare(Object? a, Object? b, EnumValueType vType) =>
      convert(a, vType).compareTo(convert(b, vType));

  /// (en) Returns the JSON-compatible form of a query value.
  /// PortableDecimal and PortableRational become their strings,
  /// and other values are returned as is.
  ///
  /// (ja) クエリの値を JSON 互換の形式で返します。
  /// PortableDecimal と PortableRational は文字列に変換され、
  /// それ以外の値はそのまま返されます。
  ///
  /// * [value] : The query value.
  static Object? toSerializable(Object? value) =>
      value is PortableDecimal || value is PortableRational
      ? value.toString()
      : value;

  /// (en) Returns the EnumValueType implied by the type of a query value,
  /// or [fallback] if the type does not imply one.
  ///
  /// (ja) クエリの値の型から決まる EnumValueType を返します。
  /// 型から決まらない場合は [fallback] を返します。
  ///
  /// * [value] : The query value.
  /// * [fallback] : The vType specified by the user.
  static EnumValueType inferVType(Object? value, EnumValueType fallback) {
    if (value is DateTime) return EnumValueType.datetime_;
    if (value is PortableDecimal) return EnumValueType.decimal_;
    if (value is PortableRational) return EnumValueType.rational_;
    return fallback;
  }
}
