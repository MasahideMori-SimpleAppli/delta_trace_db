/// ISO 8601 date-time strings accepted by datetime_. The same pattern is used
/// in the Python version so that both accept exactly the same strings.
/// The date and the time each use either the extended (with separators) or
/// the basic (without separators) format consistently.
/// Groups: 1 year, 3 month, 4 day, 5 hour, 7 minute, 8 second,
/// 9 offset hour, 10 offset minute (2 and 6 are the separators).
final RegExp _dateTimePattern = RegExp(
  r'^([0-9]{4})(-?)([0-9]{2})\2([0-9]{2})'
  r'(?:[T ]([0-9]{2})(?:(:?)([0-9]{2})(?:\6([0-9]{2})(?:[.,][0-9]+)?)?)?'
  r'(?:Z|[+-]([0-9]{2})(?::?([0-9]{2}))?)?)?$',
);

/// (en) Date-time parsing for EnumValueType.datetime_ that gives the same
/// results as the Python version.
/// DateTime.parse silently carries over out-of-range values
/// (e.g. month 13 becomes January of the next year), so values are validated
/// before parsing.
///
/// (ja) EnumValueType.datetime_ 用の、Python版と同じ結果になる日時の解析です。
/// DateTime.parse は範囲外の値を黙って繰り上げる（例：13月は翌年1月になる）ため、
/// 解析の前に値を検査します。
class UtilDateTime {
  /// (en) Parses an ISO 8601 string, or returns null if the format is not
  /// supported or a component is out of range
  /// (month 1-12, day within the month, hour 0-23, minute and second 0-59,
  /// offset hour 0-23 and minute 0-59).
  ///
  /// (ja) ISO 8601 の文字列を解析します。形式に対応していない場合や、
  /// 値が範囲外の場合（月1-12、日はその月の日数以内、時0-23、分と秒0-59、
  /// オフセットの時0-23と分0-59）は null を返します。
  ///
  /// * [text] : The string to parse.
  static DateTime? tryParse(String text) {
    final RegExpMatch? m = _dateTimePattern.firstMatch(text);
    if (m == null) return null;
    int? g(int i) => m.group(i) == null ? null : int.parse(m.group(i)!);
    final int year = g(1)!;
    final int month = g(3)!;
    final int day = g(4)!;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > DateTime.utc(year, month + 1, 0).day) return null;
    if ((g(5) ?? 0) > 23 || (g(7) ?? 0) > 59 || (g(8) ?? 0) > 59) return null;
    if ((g(9) ?? 0) > 23 || (g(10) ?? 0) > 59) return null;
    return DateTime.tryParse(text);
  }

  /// (en) Checks a naiveUtcOffsetMinutes argument.
  ///
  /// (ja) naiveUtcOffsetMinutes 引数を検査します。
  ///
  /// * [minutes] : null, or an offset from UTC in minutes
  /// (greater than -1440 and less than 1440).
  ///
  /// Throws [ArgumentError] if the value is out of range.
  static void checkOffset(int? minutes) {
    if (minutes != null && (minutes <= -1440 || minutes >= 1440)) {
      throw ArgumentError.value(
        minutes,
        "naiveUtcOffsetMinutes",
        "must be greater than -1440 and less than 1440",
      );
    }
  }

  /// (en) Returns [d] as a UTC DateTime. A naive (non-UTC) DateTime is
  /// interpreted as a local time at UTC + [offsetMinutes], regardless of the
  /// timezone of the running machine.
  ///
  /// (ja) [d] を UTC の DateTime として返します。タイムゾーン無し（UTCでない）の
  /// DateTime は、実行環境のタイムゾーンに関係なく、UTC + [offsetMinutes] の
  /// 時刻として解釈されます。
  ///
  /// * [d] : The date-time.
  /// * [offsetMinutes] : The offset from UTC in minutes for naive values.
  static DateTime toUtc(DateTime d, int offsetMinutes) {
    if (d.isUtc) return d;
    return DateTime.utc(
      d.year,
      d.month,
      d.day,
      d.hour,
      d.minute,
      d.second,
      d.millisecond,
      d.microsecond,
    ).subtract(Duration(minutes: offsetMinutes));
  }
}
