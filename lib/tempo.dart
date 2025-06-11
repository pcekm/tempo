/// A date and time library that replaces the standard
/// `dart:core` [DateTime] and [Duration] classes.
///
/// This is heavily inspired by the `java.time` package in Java 8+,
/// although there are plenty of differences.
///
/// # Overview
///
/// This library can be broken down into four main categories:
/// local dates and times, absolute dates and times, periods and
/// timespans, time zone lookups.
///
/// - [Local dates and times](../topics/Local%20times-topic.html)
/// - [Absolute dates and times](../topics/Absolute%20times-topic.html)
/// - [Relative time periods](../topics/Relative%20times-topic.html)
/// - [Time zone lookups](../topics/Time%20zone%20lookups-topic.html)
///
/// All of the classes have constructors and methods for converting from one
/// type to another. (Including [DateTime] and [Duration] via extensions.).
/// Here are some examples:
///
/// ```dart
/// var dt = DateTime.utc(2025, 1, 1);
/// dt.toLocal() == LocalDate(2025, 1, 1);
/// dt.toInstant() == Instant.fromUnix(Timespan(seconds: 1735689600));
/// dt.atOffset(ZoneOffset(-5)) =
///   OffsetDateTime(ZoneOffset(-5), 2024, 12, 31, 19, 0);
/// dt.inTimeZone('America/New_York') ==
///   ZonedDateTime.inTimeZone('America/New_York', 2024, 12, 31, 19, 0);
///
/// var LocalDateTime ldt = LocalDateTime(2025, 1, 1);
/// ldt.inTimeZone('America/New_York') ==
///    ZonedDateTime.inTimeZone('America/New_York', 2025, 1, 1);
///
/// var zdt = ZonedDateTime(2025, 1, 1);
/// zdt.toLocal() == LocalDateTime(2025, 1, 1);
/// ```
library;

import 'dart:math';

import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';

import 'src/tempo/common.dart';
import 'src/tempo/julian_day.dart';
import 'timezone.dart';

export 'timezone.dart'
    show
        allTimeZones,
        timeZonesForCountry,
        timeZonesByProximity,
        ZoneDescription;

part 'src/tempo/__period_arithmetic.dart';
part 'src/tempo/extensions.dart';
part 'src/tempo/has_date.dart';
part 'src/tempo/has_date_time.dart';
part 'src/tempo/has_instant.dart';
part 'src/tempo/has_time.dart';
part 'src/tempo/instant.dart';
part 'src/tempo/iso8601.dart';
part 'src/tempo/local_date.dart';
part 'src/tempo/local_date_time.dart';
part 'src/tempo/local_time.dart';
part 'src/tempo/named_zone_offset.dart';
part 'src/tempo/offset_date_time.dart';
part 'src/tempo/period.dart';
part 'src/tempo/timespan.dart';
part 'src/tempo/weekday.dart';
part 'src/tempo/zone_offset.dart';
part 'src/tempo/zoned_date_time.dart';
