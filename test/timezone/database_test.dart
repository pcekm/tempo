import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

class HasZoneId extends CustomMatcher {
  HasZoneId(matcher) : super('Object with zoneId of', 'zoneId', matcher);
  @override
  Object? featureValueOf(actual) => actual.zoneId;
}

void main() {
  // TODO: Need a test version of this.
  final db = Database();

  test('zoneRulesFor', () {
    var got = db.zoneRulesFor('Europe/Tallinn');
    expect(got, isNotNull);
    expect(got!.transitions, hasLength(greaterThan(10)));
    expect(got.rule.stdName, 'EET');
    expect(got.rule.stdOffset, ZoneOffset(2));
    expect(got.rule.dstName, 'EEST');
  });

  test('transitions correctly sorted', () {
    for (var z in db.allZoneRules()) {
      var rules = db.zoneRulesFor(z.zoneId)!;
      var transitions = rules.transitions.map((e) => e.transitionTime).toList();
      expect(transitions.isSorted((a, b) => a.compareTo(b)), isTrue);
    }
  });

  group('offsetFor', () {
    final rules = db.zoneRulesFor('America/Los_Angeles')!;

    test('before first transition', () {
      var offset = rules.offsetFor(Instant.minimum);
      expect(offset.name, 'LMT');
      expect(offset.isDst, isFalse);
    });

    test('in the middle std', () {
      var offset = rules.offsetFor(OffsetDateTime(ZoneOffset(0), 2000, 1, 1));
      expect(offset.name, 'PST');
      expect(offset.isDst, false);
      expect(offset, ZoneOffset(-8));
    });

    test('in the middle dst', () {
      var offset = rules.offsetFor(OffsetDateTime(ZoneOffset(0), 2000, 7, 1));
      expect(offset.name, 'PDT');
      expect(offset.isDst, true);
      expect(offset, ZoneOffset(-7));
    });

    test('after the last transition std', () {
      var offset = rules.offsetFor(OffsetDateTime(ZoneOffset(0), 9999, 1, 1));
      expect(offset.name, 'PST');
      expect(offset.isDst, false);
      expect(offset, ZoneOffset(-8));
    });

    test('after the last transition dst', () {
      var offset = rules.offsetFor(OffsetDateTime(ZoneOffset(0), 9999, 7, 1));
      expect(offset.name, 'PDT');
      expect(offset.isDst, true);
      expect(offset, ZoneOffset(-7));
    });

    test('all zones decode without error', () {
      Instant now = Instant.now();
      // This isn't really all time zones. Just those listed in zone1970.tab.
      for (var z in db.allZoneRules()) {
        try {
          db.zoneRulesFor(z.zoneId)!.offsetFor(now);
        } catch (e, stacktrace) {
          fail('Zone ${z.zoneId} exception: $e\n$stacktrace');
        }
      }
    });
  });

  test('allZoneRules() smoke test', () {
    var zones = db.allZoneRules();
    expect(zones, hasLength(greaterThan(100)));
  });

  test('forCountry()', () {
    var zones = db.forCountry('ee');
    expect(zones, hasLength(1));
    expect(zones[0], HasZoneId('Europe/Tallinn'));
    zones = db.forCountry('US');
    expect(zones, hasLength(greaterThan(10)));
    expect(zones, contains(HasZoneId('America/Juneau')));
  });

  group('byProximity()', () {
    test('without country', () {
      var zones = db.byProximity(54.517249, -128.599528);
      expect(zones, hasLength(equals(allTimeZones().length)));

      expect(zones[0], HasZoneId('America/Metlakatla'));
      expect(zones[1],
          HasZoneId('America/Vancouver')); // Correct for the coordinates
      expect(zones[2], HasZoneId('America/Juneau'));
    });

    test('with country', () {
      var zones = db.byProximity(54.517249, -128.599528, 'CA');

      expect(zones[0],
          HasZoneId('America/Vancouver')); // Correct for the coordinates
      expect(zones[1], HasZoneId('America/Fort_Nelson'));
      expect(zones[2], HasZoneId('America/Whitehorse'));
    });

    test('kiritimati', () {
      var zones = db.byProximity(1.87, -157.43);

      expect(zones[0], HasZoneId('Pacific/Kiritimati'));
      expect(zones[1], HasZoneId('Pacific/Honolulu'));
    });

    test('east of the antimeridian', () {
      // Cicia Island, Fiji:
      var zones = db.byProximity(-17.7554, -179.3130);

      expect(zones[0], HasZoneId('Pacific/Fiji'));
    });

    test('west of the antimeridian', () {
      // Viti Levu Island, Fiji:
      var zones = db.byProximity(-17.8, 178);

      expect(zones[0], HasZoneId('Pacific/Fiji'));
    });

    test('north of the equator', () {
      // Medan, Indonesia:
      var zones = db.byProximity(3.589444, 98.673889);

      // There are lots of time zones near Medan. As long as Jakarta is
      // in the top results, it's fine.
      expect(zones.take(6), contains(HasZoneId('Asia/Jakarta')));
    });

    test('south of the equator', () {
      // Jakarta, Indonesia:
      var zones = db.byProximity(-6.175, 106.8275);

      expect(zones[0], HasZoneId('Asia/Jakarta'));
    });
  });
}
