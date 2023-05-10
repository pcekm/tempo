part of '../../tempo.dart';

/// Pads an integer up to [digits]. Negative signs are not counted as a digit.
String _zeroPad(int n, [int digits = 2]) {
  var sign = '';
  if (n < 0) {
    sign = '-';
    n = -n;
  }
  return sign + '$n'.padLeft(digits, '0');
}

/// Formats a [HasDate] as an ISO 8601 string.
String _iso8601Date(HasDate date) {
  var year =
      '${date.year == 0 || date.year > 9999 ? "+" : ""}${_zeroPad(date.year, 4)}';
  return '$year-${_zeroPad(date.month)}-${_zeroPad(date.day)}';
}

/// Parss an ISO 8601 date string.
LocalDate _parseIso8601Date(String dateString) {
  var s = StringScanner(dateString);
  var date = _scanIso8601Date(s);
  s.expectDone();
  return date;
}

LocalDate _scanIso8601Date(StringScanner s) {
  if (s.scan(RegExp(r'(\d{4})(\d{2})(\d{2})'))) {
    return LocalDate(
      int.parse(s.lastMatch!.group(1)!),
      int.parse(s.lastMatch!.group(2)!),
      int.parse(s.lastMatch!.group(3)!),
    );
  }
  s.expect(RegExp(r'([+-]?\d{4,})-(\d{2})(?:-(\d{2}))?'));
  return LocalDate(
    int.parse(s.lastMatch!.group(1)!),
    int.parse(s.lastMatch!.group(2)!),
    int.parse(s.lastMatch!.group(3) ?? '1'),
  );
}

/// Parses an ISO 8601 time string.
LocalTime _parseIso8601Time(String timeString) {
  var s = StringScanner(timeString);
  s.scan('T');
  var time = _scanIso8601Time(s);
  s.expectDone();
  return time;
}

LocalTime _scanIso8601Time(StringScanner s) {
  var hour = 0;
  var minute = 0;
  var second = 0;
  var nanosecond = 0;
  s.expect(RegExp(r'(\d{2})'));
  hour = int.parse(s.lastMatch!.group(1)!);
  if (s.scan(RegExp(r':?(\d{2})'))) {
    minute = int.parse(s.lastMatch!.group(1)!);
  }
  if (s.scan(RegExp(r':?(\d{2})(?:\.(\d+))?'))) {
    second = int.parse(s.lastMatch!.group(1)!);
    var decimalString = s.lastMatch!.group(2) ?? '0';
    // Add zeros or trim to make exactly 9 digits (nanoseconds):
    decimalString = decimalString.padRight(9, '0');
    decimalString = decimalString.substring(0, 9);
    nanosecond = int.parse(decimalString);
  }
  return LocalTime(hour, minute, second, nanosecond);
}

/// Parses an ISO 8601 zone offset string.
ZoneOffset _parseIso8601Offset(String offset) =>
    _scanIso8601Offset(StringScanner(offset), true);

ZoneOffset _scanIso8601Offset(StringScanner s, [bool must = false]) {
  if (s.scan('Z')) {
    return ZoneOffset(0);
  }
  final re = RegExp(r'([+-])(\d{2})(?::?(\d{2})(?::?(\d{2}))?)?');
  if (must || s.scan(re)) {
    if (must) {
      s.expect(re);
    }
    var sign = s.lastMatch!.group(1) == '-' ? -1 : 1;
    return ZoneOffset(
        sign * int.parse(s.lastMatch!.group(2)!),
        sign * int.parse(s.lastMatch!.group(3) ?? '0'),
        sign * int.parse(s.lastMatch!.group(4) ?? '0'));
  }
  return ZoneOffset(0);
}

/// Parses an ISO 8601 datetime.
OffsetDateTime _parseIso8160DateTime(String dateStr) {
  var s = StringScanner(dateStr);
  var date = _scanIso8601Date(s);
  var time = LocalTime(0);
  var offset = ZoneOffset(0);
  if (s.scan(RegExp('T'))) {
    time = _scanIso8601Time(s);
    offset = _scanIso8601Offset(s);
  }
  return OffsetDateTime.fromLocalDateTime(
      LocalDateTime.combine(date, time), offset);
}

/// Formats a [HasTime] as an ISO 8601 string.
String _iso8601Time(HasTime time) {
  var s = '${_zeroPad(time.hour)}:${_zeroPad(time.minute)}';
  if (time.second != 0 || time.nanosecond != 0) {
    s += ':${_zeroPad(time.second)}';
  }
  if (time.nanosecond != 0) {
    s += '.${_zeroPad(time.nanosecond, 9).replaceFirst(RegExp(r"0+$"), "")}';
  }
  return s;
}

/// Formats a [ZoneOffset] as an ISO 8601 string. Use [withZulu] to convert
/// zero offsets to 'Z' instead of '00:00'.
String _iso8601ZoneOffset(ZoneOffset offset, [bool withZulu = false]) {
  if (withZulu && offset == ZoneOffset(0)) {
    return 'Z';
  }
  var sign = offset.hours >= 0 ? '+' : '-';
  var hours = _zeroPad(offset.hours.abs());
  var minutes = _zeroPad(offset.minutes.abs());
  var s = '$sign$hours$minutes';
  if (offset.seconds != 0) {
    s += _zeroPad(offset.seconds.abs());
  }
  return s;
}

/// Formats a [HasDateTime] as an ISO 8601 string.
String _iso8601DateTime(HasDateTime dateTime,
    [ZoneOffset? offset, bool withZulu = false]) {
  var s = '${_iso8601Date(dateTime)}T${_iso8601Time(dateTime)}';
  if (offset != null) {
    s += _iso8601ZoneOffset(offset, withZulu);
  }
  return s;
}

/// An ISO 8601 period.
class _IsoPeriod {
  int years = 0;
  int months = 0;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  int nanoseconds = 0;
}

/// Scans an ISO 8601 period. Only supports fractional seconds.
_IsoPeriod _parseIso8601Period(String periodString) {
  var s = StringScanner(periodString);
  s.expect('P');
  int num = 0;
  bool scanPart(String type) {
    if (!s.scan(RegExp('([+-]?\\d+)$type'))) {
      return false;
    }
    num = int.parse(s.lastMatch!.group(1)!);
    return true;
  }

  var period = _IsoPeriod();
  period.years = scanPart('Y') ? num : 0;
  period.months = scanPart('M') ? num : 0;
  period.days = scanPart('W') ? 7 * num : 0;
  period.days += scanPart('D') ? num : 0;

  if (!s.scan('T')) {
    s.expectDone();
    return period;
  }

  period.hours = scanPart('H') ? num : 0;
  period.minutes = scanPart('M') ? num : 0;

  if (s.scan(RegExp(r'([+-]?\d+)(?:\.(\d+))?S'))) {
    var secs = s.lastMatch?.group(1) ?? '0';
    var sign = secs.startsWith('-') ? -1 : 1;
    if (secs == '-') {
      secs = '0';
    }
    period.seconds = int.parse(secs);
    var frac = s.lastMatch?.group(2) ?? '0';
    frac = frac.substring(0, min(frac.length, 9));
    frac = frac.padRight(9, '0');
    period.nanoseconds = sign * int.parse(frac);
  }

  s.expectDone();
  return period;
}
