/// ISO 8601 date-time strings accepted by datetime_. The same pattern is used
/// in the Python version so that both accept exactly the same strings.
/// The date and the time each use either the extended (with separators) or
/// the basic (without separators) format consistently.
/// Groups: 1 year, 3 month, 4 day, 5 hour, 7 minute, 8 second,
/// 9 fraction of a second, 10 "Z", 11 offset sign, 12 offset hour,
/// 13 offset minute (2 and 6 are the separators).
final RegExp _dateTimePattern = RegExp(
  r'^([0-9]{4})(-?)([0-9]{2})\2([0-9]{2})'
  r'(?:[T ]([0-9]{2})(?:(:?)([0-9]{2})(?:\6([0-9]{2})(?:[.,]([0-9]+))?)?)?'
  r'(?:(Z)|([+-])([0-9]{2})(?::?([0-9]{2}))?)?)?$',
);

/// (en) A date-time value of EnumValueType.datetime_.
/// If [isNaive] is false, [value] is the time in UTC.
/// If [isNaive] is true, the value has no time zone, and [value] is a UTC
/// DateTime whose fields hold its date and time as they are.
///
/// (ja) EnumValueType.datetime_ の日時の値です。
/// [isNaive] が false の場合、[value] は UTC での時刻です。
/// [isNaive] が true の場合はタイムゾーン無しの値で、[value] はその日時を
/// そのままフィールドに持つ UTC の DateTime です。
typedef NaiveOrUtc = ({DateTime value, bool isNaive});

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
  /// (en) Matches an ISO 8601 string, or returns null if the format is not
  /// supported or a component is out of range
  /// (month 1-12, day within the month, hour 0-23, minute and second 0-59,
  /// offset hour 0-23 and minute 0-59).
  ///
  /// (ja) ISO 8601 の文字列を照合します。形式に対応していない場合や、
  /// 値が範囲外の場合（月1-12、日はその月の日数以内、時0-23、分と秒0-59、
  /// オフセットの時0-23と分0-59）は null を返します。
  ///
  /// * [text] : The string to match.
  static RegExpMatch? _match(String text) {
    final RegExpMatch? m = _dateTimePattern.firstMatch(text);
    if (m == null) return null;
    int g(int i) => m.group(i) == null ? 0 : int.parse(m.group(i)!);
    final int year = g(1);
    final int month = g(3);
    final int day = g(4);
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > DateTime.utc(year, month + 1, 0).day) return null;
    if (g(5) > 23 || g(7) > 59 || g(8) > 59) return null;
    if (g(12) > 23 || g(13) > 59) return null;
    return m;
  }

  /// (en) Parses an ISO 8601 string without converting it to the local time
  /// of the running machine, so the result does not depend on its time zone
  /// (e.g. a time skipped by daylight saving time is not shifted).
  /// Returns null if the format is not supported or a component is out of
  /// range (month 1-12, day within the month, hour 0-23, minute and second
  /// 0-59, offset hour 0-23 and minute 0-59).
  /// Digits of a second beyond microseconds are truncated,
  /// the same as DateTime.parse.
  ///
  /// (ja) ISO 8601 の文字列を、実行環境のローカル時刻に変換せずに解析します。
  /// そのため結果は実行環境のタイムゾーンに依存しません
  /// （例：夏時間で飛ばされる時刻がずれません）。
  /// 形式に対応していない場合や、値が範囲外の場合（月1-12、日はその月の日数以内、
  /// 時0-23、分と秒0-59、オフセットの時0-23と分0-59）は null を返します。
  /// マイクロ秒より細かい秒の桁は、DateTime.parse と同じく切り捨てます。
  ///
  /// * [text] : The string to parse.
  static NaiveOrUtc? tryParse(String text) {
    final RegExpMatch? m = _match(text);
    if (m == null) return null;
    int g(int i) => m.group(i) == null ? 0 : int.parse(m.group(i)!);
    final String fraction = (m.group(9) ?? '').padRight(6, '0');
    final DateTime t = DateTime.utc(
      g(1),
      g(3),
      g(4),
      g(5),
      g(7),
      g(8),
      int.parse(fraction.substring(0, 3)),
      int.parse(fraction.substring(3, 6)),
    );
    if (m.group(10) != null) return (value: t, isNaive: false);
    if (m.group(11) == null) return (value: t, isNaive: true);
    final int offset = (m.group(11) == '-' ? -1 : 1) * (g(12) * 60 + g(13));
    return (value: t.subtract(Duration(minutes: offset)), isNaive: false);
  }

  /// (en) Returns [d] as a NaiveOrUtc. A non-UTC DateTime is treated as a
  /// naive value whose date and time are the fields of [d].
  ///
  /// (ja) [d] を NaiveOrUtc として返します。UTCでない DateTime は、
  /// [d] の各フィールドの日時を持つタイムゾーン無しの値として扱います。
  ///
  /// * [d] : The date-time.
  static NaiveOrUtc fromDateTime(DateTime d) {
    if (d.isUtc) return (value: d, isNaive: false);
    return (
      value: DateTime.utc(
        d.year,
        d.month,
        d.day,
        d.hour,
        d.minute,
        d.second,
        d.millisecond,
        d.microsecond,
      ),
      isNaive: true,
    );
  }

  /// (en) Returns [d] as a UTC DateTime. A naive value is interpreted as a
  /// time at UTC + [offsetMinutes].
  ///
  /// (ja) [d] を UTC の DateTime として返します。タイムゾーン無しの値は
  /// UTC + [offsetMinutes] の時刻として解釈されます。
  ///
  /// * [d] : The date-time.
  /// * [offsetMinutes] : The offset from UTC in minutes for naive values.
  static DateTime toUtc(NaiveOrUtc d, int offsetMinutes) {
    if (!d.isNaive) return d.value;
    return d.value.subtract(Duration(minutes: offsetMinutes));
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
}
