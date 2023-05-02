import 'package:goodtime/goodtime.dart';
import 'package:goodtime/src/zonedb.dart';
import 'package:test/test.dart';

class HasZoneId extends CustomMatcher {
  HasZoneId(matcher)
      : super('ZoneDescription with zoneId of', 'zoneId', matcher);
  @override
  Object? featureValueOf(actual) => actual.zoneId;
}

void main() {
  test('smoke test', () {
    var got = lookupTimeZone(
        'Europe/Tallinn', OffsetDateTime(ZoneOffset(2), 2023, 1, 1));
    expect(got, isNotNull);
    expect(got!.designation, 'EET');
  });

  test('id normalization', () {
    var got = lookupTimeZone('   America/Los _ Angeles   ',
        OffsetDateTime(ZoneOffset(-7), 2023, 6, 1));
    expect(got, isNotNull);
    expect(got!.designation, 'PDT');
  });

  test('allTimeZones() smoke test', () {
    var zones = allTimeZones();
    expect(zones, hasLength(greaterThan(100)));
  });

  test('all zones decode without error', () {
    Instant now = Instant.now();
    for (var z in allTimeZones()) {
      try {
        lookupTimeZone(z.zoneId, now);
      } catch (e, stacktrace) {
        fail('Zone ${z.zoneId} exception: $e\n$stacktrace');
      }
    }
  });

  test('timeZonesForCountry()', () {
    var zones = timeZonesForCountry('ee');
    expect(zones, hasLength(1));
    expect(zones[0], HasZoneId('Europe/Tallinn'));
    zones = timeZonesForCountry('US');
    expect(zones, hasLength(greaterThan(10)));
    expect(zones, contains(HasZoneId('America/Juneau')));
  });

  group('timeZonesByProximity()', () {
    test('without country', () {
      var zones = timeZonesByProximity(54.517249, -128.599528);
      expect(zones, hasLength(equals(allTimeZones().length)));

      expect(zones[0], HasZoneId('America/Metlakatla'));
      expect(zones[1],
          HasZoneId('America/Vancouver')); // Correct for the coordinates
      expect(zones[2], HasZoneId('America/Juneau'));
    });

    test('with country', () {
      var zones = timeZonesByProximity(54.517249, -128.599528, 'CA');

      expect(zones[0],
          HasZoneId('America/Vancouver')); // Correct for the coordinates
      expect(zones[1], HasZoneId('America/Fort Nelson'));
      expect(zones[2], HasZoneId('America/Whitehorse'));
    });

    test('kiritimati', () {
      var zones = timeZonesByProximity(1.87, -157.43);

      expect(zones[0], HasZoneId('Pacific/Kiritimati'));
      expect(zones[1], HasZoneId('Pacific/Honolulu'));
    });

    test('east of the antimeridian', () {
      // Cicia Island, Fiji:
      var zones = timeZonesByProximity(-17.7554, -179.3130);

      expect(zones[0], HasZoneId('Pacific/Fiji'));
    });

    test('west of the antimeridian', () {
      // Viti Levu Island, Fiji:
      var zones = timeZonesByProximity(-17.8, 178);

      expect(zones[0], HasZoneId('Pacific/Fiji'));
    });

    test('north of the equator', () {
      // Medan, Indonesia:
      var zones = timeZonesByProximity(3.589444, 98.673889);

      // There are lots of time zones near Medan. As long as Jakarta is
      // in the top results, it's fine.
      expect(zones.take(6), contains(HasZoneId('Asia/Jakarta')));
    });

    test('south of the equator', () {
      // Jakarta, Indonesia:
      var zones = timeZonesByProximity(-6.175, 106.8275);

      expect(zones[0], HasZoneId('Asia/Jakarta'));
    });
  });
}
