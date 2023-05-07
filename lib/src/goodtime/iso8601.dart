part of '../../goodtime.dart';

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
