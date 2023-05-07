/// Support for doing something awesome.
///
/// More dartdocs go here.
library goodtime;

import 'dart:math';

import 'package:goodtime/src/zonedb.dart';
import 'package:sprintf/sprintf.dart';

import 'src/goodtime/common.dart';
import 'src/goodtime/julian_day.dart';

export 'src/zonedb.dart'
    show
        ZoneDescription,
        allTimeZones,
        timeZonesByProximity,
        timeZonesForCountry;

part 'src/goodtime/__period_arithmetic.dart';
part 'src/goodtime/iso8601.dart';
part 'src/goodtime/has_date_time.dart';
part 'src/goodtime/has_date.dart';
part 'src/goodtime/has_instant.dart';
part 'src/goodtime/has_time.dart';
part 'src/goodtime/instant.dart';
part 'src/goodtime/local_date_time.dart';
part 'src/goodtime/local_date.dart';
part 'src/goodtime/local_time.dart';
part 'src/goodtime/offset_date_time.dart';
part 'src/goodtime/period.dart';
part 'src/goodtime/timespan.dart';
part 'src/goodtime/weekday.dart';
part 'src/goodtime/zone_offset.dart';
part 'src/goodtime/zoned_date_time.dart';
