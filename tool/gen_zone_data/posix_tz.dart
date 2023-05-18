import 'package:string_scanner/string_scanner.dart';
import 'package:tempo/src/zonedb.dart';
import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';

/// Contains and interprets a subset of Posix-formatted TZ environment
/// variables.
///
/// This does not support Julian day offsets, and it requires explicit
/// daylight savings time changover rules.
///
/// See the [tzset(3)](https://man7.org/linux/man-pages/man3/tzset.3.html)
/// manpage for details.
class PosixTz {
  final ZoneTransitionRule rule;

  PosixTz._(this.rule);

  /// Constructs a posix timezone specifier from a TZ string.
  ///
  /// See the [tzset(3)](https://man7.org/linux/man-pages/man3/tzset.3.html)
  /// manpage for the format.
  factory PosixTz(String tzString) {
    var b = ZoneTransitionRuleBuilder();

    var s = StringScanner(tzString);

    s.scan(RegExp(r'\s*')); // Eat leading whitespace
    b.stdName = _scanName(s, true)!;
    // Negated because the TZ variable was designed such that positive
    // numbers equal negative offsets. e.g. "MST7" means an offset of -7:
    var stdOffset = -_scanTimespan(s, true)!;
    b.stdOffset = _toOffset(stdOffset);
    b.dstName = _scanName(s, false);
    if (b.dstName != null) {
      b.dstOffset = _toOffset(_scanTimespan(s, false));
      b.dstOffset ??= _toOffset(Timespan(hours: 1) + stdOffset);
      s.expect(',');
      b.dstStartRule = _scanPartialDateTime(s).toBuilder();
      s.expect(',');
      b.stdStartRule = _scanPartialDateTime(s).toBuilder();
    }

    s.scan(RegExp(r'\s*')); // Eat trailing whitespace
    s.expectDone();

    return PosixTz._(b.build());
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

  static TimeChangeRule _scanPartialDateTime(StringScanner s) {
    s.expect(RegExp(r'M(\d+)\.(\d+)\.(\d+)'));
    var month = int.parse(s.lastMatch!.group(1)!);
    var week = int.parse(s.lastMatch!.group(2)!);
    var w = int.parse(s.lastMatch!.group(3)!);
    var day = Weekday.values[(w - 1) % 7 + 1];
    var time = LocalTime(2); // Time change defaults to 2 AM wall time.
    if (s.scan('/')) {
      time = LocalTime().plusTimespan(_scanTimespan(s)!);
    }
    return TimeChangeRule((b) => b
      ..month = month
      ..week = week
      ..day = day
      ..time = time);
  }

  /// Converts [Timespan] to [ZoneOffset] handling nulls.
  static ZoneOffset? _toOffset(Timespan? span) {
    if (span == null) {
      return null;
    }
    return ZoneOffset.fromTimespan(span);
  }

  TimeZone timeZoneFor(HasInstant instant) {
    var offset = rule.offsetFor(instant);
    return TimeZone(offset, offset.name, offset.isDst);
  }
}
