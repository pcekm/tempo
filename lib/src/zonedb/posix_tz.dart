part of '../../zonedb.dart';

/// Contains and interprets a subset of Posix-formatted TZ environment
/// variables.
///
/// This does not support Julian day offsets, and it requires explicit
/// daylight savings time changover rules.
///
/// See the [tzset(3)](https://man7.org/linux/man-pages/man3/tzset.3.html)
/// manpage for details.
class PosixTz {
  final String _stdName;
  final Timespan _stdOffset;
  final String? _dstName;
  final Timespan? _dstOffset;
  final _DstChangeTime? _dstStartRule;
  final _DstChangeTime? _stdStartRule;

  PosixTz._(
    this._stdName,
    this._stdOffset,
    this._dstName,
    this._dstOffset,
    this._dstStartRule,
    this._stdStartRule,
  );

  /// Constructs a posix timezone specifier from a TZ string.
  ///
  /// See the [tzset(3)](https://man7.org/linux/man-pages/man3/tzset.3.html)
  /// manpage for the format.
  factory PosixTz(String tzString) {
    String stdName;
    Timespan stdOffset;
    String? dstName;
    Timespan? dstOffset;
    _DstChangeTime? dstStart;
    _DstChangeTime? dstEnd;

    var s = StringScanner(tzString);

    s.scan(RegExp(r'\s*')); // Eat leading whitespace
    stdName = _scanName(s, true)!;
    stdOffset = _scanOffset(s)!;
    dstName = _scanName(s, false);
    if (dstName != null) {
      dstOffset = _scanOffset(s, false);
      dstOffset ??= Timespan(hours: 1) + stdOffset;
      s.expect(',');
      dstStart = _scanPartialDateTime(s);
      s.expect(',');
      dstEnd = _scanPartialDateTime(s);
    }

    s.scan(RegExp(r'\s*')); // Eat trailing whitespace
    s.expectDone();

    return PosixTz._(
      stdName,
      stdOffset,
      dstName,
      dstOffset,
      dstStart,
      dstEnd,
    );
  }

  static String? _scanName(StringScanner s, [bool expect = true]) {
    if (s.scan(RegExp(r'[a-zA-Z]{3,}'))) {
      return s.lastMatch!.group(0)!;
    } else if (s.scan(RegExp(r'<([a-zA-Z0-9+-]{3,})>'))) {
      return s.lastMatch!.group(1)!;
    } else if (expect) {
      s.error(
          'Expected standard zone abbreviation [a-z] or <[a-z0-9+-]> of at least three characters.');
    } else {
      return null;
    }
  }

  static Timespan? _scanOffset(StringScanner s, [bool expect = true]) {
    final re = RegExp(r'([+-]?\d+)(?::(\d+)?(?::(\d+))?)?');
    if (expect) {
      s.expect(re);
    } else if (!s.scan(re)) {
      return null;
    }
    var hour = int.parse(s.lastMatch!.group(1)!);
    var minute = int.parse(s.lastMatch!.group(2) ?? '0');
    var second = int.parse(s.lastMatch!.group(3) ?? '0');
    if (hour < 0) {
      minute = -minute;
      second = -second;
    }
    // Negated because the TZ variable was designed such that positive
    // numbers equal negative offsets. e.g. "MST7" means an offset of -7.
    return -Timespan(hours: hour, minutes: minute, seconds: second);
  }

  static _DstChangeTime _scanPartialDateTime(StringScanner s) {
    s.expect(RegExp(r'M(\d+)\.(\d+)\.(\d+)'));
    var month = int.parse(s.lastMatch!.group(1)!);
    var week = int.parse(s.lastMatch!.group(2)!);
    var w = int.parse(s.lastMatch!.group(3)!);
    var weekday = Weekday.values[(w - 1) % 7 + 1];
    var time = LocalTime(2); // Time change defaults to 2 AM wall time.
    if (s.scan(RegExp(r'/(\d+)(?::(\d+)?(?::(\d+))?)?'))) {
      var hour = int.parse(s.lastMatch!.group(1)!);
      var minute = int.parse(s.lastMatch!.group(2) ?? '0');
      var second = int.parse(s.lastMatch!.group(3) ?? '0');
      time = LocalTime(hour, minute, second);
    }
    return _DstChangeTime(month, week, weekday, time);
  }

  TimeZone timeZoneFor(HasInstant instant) {
    if (_dstName == null) {
      return TimeZone(ZoneOffset.fromTimespan(_stdOffset), _stdName, false);
    }

    var std =
        OffsetDateTime.fromInstant(instant, ZoneOffset.fromTimespan(_stdOffset))
            .toLocal();
    var dst = OffsetDateTime.fromInstant(
            instant, ZoneOffset.fromTimespan(_dstOffset!))
        .toLocal();
    var dstStart = _dstStartRule!.forYear(std.year);
    var stdStart = _stdStartRule!.forYear(std.year);

    if (dstStart < stdStart) {
      if (std >= dstStart && dst < stdStart) {
        return TimeZone(ZoneOffset.fromTimespan(_dstOffset!), _dstName!, true);
      } else {
        return TimeZone(ZoneOffset.fromTimespan(_stdOffset), _stdName, false);
      }
    } else {
      // "Winter time." Hello, Ireland.
      // var lastDstStart = dstStartRule.forYear(std.year - 1);
      if (std >= stdStart && dst < dstStart) {
        return TimeZone(ZoneOffset.fromTimespan(_stdOffset), _stdName, false);
      } else {
        return TimeZone(ZoneOffset.fromTimespan(_dstOffset!), _dstName!, true);
      }
    }
  }
}

/// A time at which a switch to or from daylight savings occurrs.
class _DstChangeTime {
  final int month;
  final int week;
  final Weekday weekday;
  final LocalTime time;

  _DstChangeTime(this.month, this.week, this.weekday, this.time);

  LocalDateTime forYear(int year) {
    var startOfWeek = LocalDateTime(
        year, month, 7 * (week - 1) + 1, time.hour, time.minute, time.second);
    var changeTime = startOfWeek.plusTimespan(
        Timespan(days: (weekday.index - startOfWeek.weekday.index) % 7));
    if (changeTime.month != month) {
      // This will only occur for week == 5, which means "the last day"
      // of the same month. Since the shortest month has exactly 4 * 7 = 28
      // days, then if skipping to the 5th week rolls over to the next month
      // we will always have to subtract exactly one week.
      changeTime = changeTime.minusTimespan(Timespan(days: 7));
    }
    return changeTime;
  }

  @override
  String toString() => '$month.$week.$weekday/$time';

  @override
  bool operator ==(Object other) =>
      other is _DstChangeTime &&
      month == other.month &&
      week == other.week &&
      weekday == other.weekday &&
      time == other.time;

  @override
  int get hashCode => Object.hash(month, week, weekday, time);
}
