import 'package:collection/collection.dart';
import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';
import 'package:test/test.dart';

class HasZoneId extends CustomMatcher {
  HasZoneId(matcher) : super('Object with zoneId of', 'zoneId', matcher);
  @override
  Object? featureValueOf(actual) => actual.zoneId;
}

// The tests in here vary between tests of functionality to tests of the
// built-in database consistency.

void main() {
  // TODO: Need a test version of this.
  final db = TimeZoneDatabase();

  test('version populated', () {
    expect(db.version, isNotEmpty);
  });

  test('zoneRulesFor', () {
    var got = db.rules['Europe/Tallinn'];
    expect(got, isNotNull);
    expect(got!.transitions, hasLength(greaterThan(10)));
    expect(got.rule.stdName, 'EET');
    expect(got.rule.stdOffset, ZoneOffset(2));
    expect(got.rule.dstName, 'EEST');
  });

  test('transitions correctly sorted', () {
    for (var rule in db.rules.values) {
      var transitions = rule.transitions.map((e) => e.transitionTime).toList();
      expect(transitions.isSorted((a, b) => a.compareTo(b)), isTrue);
    }
  });

  group('offsetFor', () {
    final rules = db.rules['America/Los_Angeles']!;

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

    test('all zones can find an offset without error', () {
      Instant now = Instant.now();
      for (var ent in db.rules.entries) {
        try {
          ent.value.offsetFor(now);
        } catch (e, stacktrace) {
          fail('Zone ${ent.key} exception: $e\n$stacktrace');
        }
      }
    });
  });

  test('descriptionsByCountry', () {
    var desc = db.descriptionsByCountry['EE'];
    expect(desc, hasLength(1));
    expect(desc[0], HasZoneId('Europe/Tallinn'));
    desc = db.descriptionsByCountry['US'];
    expect(desc, hasLength(greaterThan(10)));
    expect(desc, contains(HasZoneId('America/Juneau')));
  });

  group('byProximity()', () {
    test('without country', () {
      var zones = db.byProximity(54.517249, -128.599528);
      expect(zones, hasLength(equals(db.descriptions.length)));

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
