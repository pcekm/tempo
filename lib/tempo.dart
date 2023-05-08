/// A date and time library that replaces the standard
/// `dart:core` [DateTime] and [Duration] classes.
///
/// This is heavily inspired by the Java 8+ time package,
/// although there are plenty of differences.
///
/// ## Local dates and times
///
/// * [LocalTime]
/// * [LocalDate]
/// * [LocalDateTime]
///
/// ## Absolute times
///
/// * [Instant]
/// * [OffsetDateTime]
/// * [ZonedDateTime]
///
/// ## Relative times
///
/// * [Timespan]
/// * [Period]
///
/// ## Time zones
///
/// * [ZoneDescription]
/// * [allTimeZones]
/// * [timeZonesByProximity]
/// * [timeZonesForCountry]
///
library tempo;

import 'dart:math';

import 'package:string_scanner/string_scanner.dart';

import 'src/tempo/common.dart';
import 'src/tempo/julian_day.dart';
import 'src/zonedb.dart';

export 'src/zonedb.dart'
    show
        ZoneDescription,
        allTimeZones,
        timeZonesByProximity,
        timeZonesForCountry;

part 'src/tempo/__period_arithmetic.dart';
part 'src/tempo/iso8601.dart';
part 'src/tempo/has_date_time.dart';
part 'src/tempo/has_date.dart';
part 'src/tempo/has_instant.dart';
part 'src/tempo/has_time.dart';
part 'src/tempo/instant.dart';
part 'src/tempo/local_date_time.dart';
part 'src/tempo/local_date.dart';
part 'src/tempo/local_time.dart';
part 'src/tempo/offset_date_time.dart';
part 'src/tempo/period.dart';
part 'src/tempo/timespan.dart';
part 'src/tempo/weekday.dart';
part 'src/tempo/zone_offset.dart';
part 'src/tempo/zoned_date_time.dart';
