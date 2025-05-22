/// Contains information about time zones (mostly for internal use).
///
/// The important bits are exported from [tempo], so you probably shouldn't
/// need to import this directly.
///
/// See:
///
///  - [allTimeZones]
///  - [timeZonesForCountry]
///  - [timeZonesByProximity]
library;

export 'src/timezone/time_change_rule.dart';
export 'src/timezone/time_zone_database.dart';
export 'src/timezone/zone_description.dart';
export 'src/timezone/zone_rules.dart';
export 'src/timezone/zone_transition.dart';
export 'src/timezone/zone_transition_rule.dart';
