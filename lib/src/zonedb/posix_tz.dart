part of '../zonedb.dart';

/// Contains and interprets a subset of Posix-formatted TZ environment
/// variables.
///
/// This does not support Julian day offsets, and it requires explicit
/// daylight savings time changover rules.
///
/// See the [tzset(3)](https://man7.org/linux/man-pages/man3/tzset.3.html)
/// manpage for details.
abstract class PosixTz implements Built<PosixTz, PosixTzBuilder> {
  static Serializer<PosixTz> get serializer => _$posixTzSerializer;

  String get stdName;
  Timespan get stdOffset;
  String? get dstName;
  Timespan? get dstOffset;
  ChangeTime? get dstStartRule;
  ChangeTime? get stdStartRule;

  PosixTz._();
  factory PosixTz._fromBuilder([void Function(PosixTzBuilder) updates]) =
      _$PosixTz;

  /// Constructs a posix timezone specifier from a TZ string.
  ///
  /// See the [tzset(3)](https://man7.org/linux/man-pages/man3/tzset.3.html)
  /// manpage for the format.
  factory PosixTz(String tzString) {
    var b = PosixTzBuilder();

    var s = StringScanner(tzString);

    s.scan(RegExp(r'\s*')); // Eat leading whitespace
    b.stdName = _scanName(s, true)!;
    // Negated because the TZ variable was designed such that positive
    // numbers equal negative offsets. e.g. "MST7" means an offset of -7:
    b.stdOffset = -_scanTimespan(s)!;
    b.dstName = _scanName(s, false);
    if (b.dstName != null) {
      b.dstOffset = _scanTimespan(s, false);
      b.dstOffset ??= Timespan(hours: 1) + b.stdOffset!;
      s.expect(',');
      b.dstStartRule = _scanPartialDateTime(s).toBuilder();
      s.expect(',');
      b.stdStartRule = _scanPartialDateTime(s).toBuilder();
    }

    s.scan(RegExp(r'\s*')); // Eat trailing whitespace
    s.expectDone();

    return b.build();
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

  static Timespan? _scanTimespan(StringScanner s, [bool expect = true]) {
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
    return Timespan(hours: hour, minutes: minute, seconds: second);
  }

  static ChangeTime _scanPartialDateTime(StringScanner s) {
    s.expect(RegExp(r'M(\d+)\.(\d+)\.(\d+)'));
    var month = int.parse(s.lastMatch!.group(1)!);
    var week = int.parse(s.lastMatch!.group(2)!);
    var w = int.parse(s.lastMatch!.group(3)!);
    var weekday = Weekday.values[(w - 1) % 7 + 1];
    var time = LocalTime(2); // Time change defaults to 2 AM wall time.
    if (s.scan('/')) {
      time = LocalTime().plusTimespan(_scanTimespan(s)!);
    }
    return ChangeTime((b) => b
      ..month = month
      ..week = week
      ..weekday = weekday
      ..time = time);
  }

  TimeZone timeZoneFor(HasInstant instant) {
    if (dstName == null) {
      return TimeZone(ZoneOffset.fromTimespan(stdOffset), stdName, false);
    }

    var std =
        OffsetDateTime.fromInstant(instant, ZoneOffset.fromTimespan(stdOffset))
            .toLocal();
    var dst =
        OffsetDateTime.fromInstant(instant, ZoneOffset.fromTimespan(dstOffset!))
            .toLocal();
    var dstStart = dstStartRule!.forYear(std.year);
    var stdStart = stdStartRule!.forYear(std.year);

    if (dstStart < stdStart) {
      if (std >= dstStart && dst < stdStart) {
        return TimeZone(ZoneOffset.fromTimespan(dstOffset!), dstName!, true);
      } else {
        return TimeZone(ZoneOffset.fromTimespan(stdOffset), stdName, false);
      }
    } else {
      // "Winter time." Hello, Ireland.
      // var lastDstStart = dstStartRule.forYear(std.year - 1);
      if (std >= stdStart && dst < dstStart) {
        return TimeZone(ZoneOffset.fromTimespan(stdOffset), stdName, false);
      } else {
        return TimeZone(ZoneOffset.fromTimespan(dstOffset!), dstName!, true);
      }
    }
  }
}
