part of '../../tempo.dart';

String _defaultZoneId = 'UTC';

/// The default time zone id.
///
/// The time zone defaults to "UTC" and may be changed by setting this value.
///
/// If you're using Flutter, you can get a better default
/// from the [flutter_timezone](https://pub.dev/packages/flutter_timezone)
/// package:
///
/// ```dart
/// import 'package:flutter_timezone/flutter_timezone.dart';
///
/// defaultZoneId = await FlutterTimeZone.getLocalTimeZone();
/// ```
String get defaultZoneId => _defaultZoneId;

set defaultZoneId(String zoneId) {
  if (!TimeZoneDatabase().rules.containsKey(zoneId)) {
    throw ArgumentError.value(zoneId, 'defaultTimeZone', 'Invalid zone id');
  }
  _defaultZoneId = zoneId;
}
