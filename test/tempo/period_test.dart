import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

Matcher hasParts({int years = 0, int months = 0, int days = 0}) => isA<Period>()
    .having((p) => p.years, 'years', years)
    .having((p) => p.months, 'months', months)
    .having((p) => p.days, 'days', days);

void main() {
  test('parse', () {
    expect(Period.parse('P1Y2M3D'), hasParts(years: 1, months: 2, days: 3));
    expect(
        Period.parse('P-1Y-2M-3D'), hasParts(years: -1, months: -2, days: -3));
    expect(Period.parse('P2W'), hasParts(days: 14));
    expect(Period.parse('P3DT1H'), hasParts(days: 3));
  });

  group('normalization', () {
    test('both positive', () {
      expect(Period(months: 12, days: 3), hasParts(years: 1, days: 3));
      expect(Period(years: 1, months: 13, days: 3),
          hasParts(years: 2, months: 1, days: 3));
      expect(Period(days: 35), hasParts(days: 35));
      expect(Period(months: 11), hasParts(months: 11));
    });

    test('+years, -months', () {
      expect(Period(years: 0, months: -1, days: 3),
          hasParts(years: 0, months: -1, days: 3));
      expect(Period(years: 0, months: -12), hasParts(years: -1));
      expect(Period(years: 0, months: -13, days: 3),
          hasParts(years: -1, months: -1, days: 3));
      expect(
          Period(years: 1, months: -1, days: 3), hasParts(months: 11, days: 3));
      expect(Period(years: 1, months: -13, days: 3),
          hasParts(months: -1, days: 3));
      expect(Period(years: 2, months: -13, days: 3),
          hasParts(months: 11, days: 3));
    });

    test('-years, +months', () {
      expect(Period(years: -1, months: 1, days: 3),
          hasParts(months: -11, days: 3));
      expect(
          Period(years: -1, months: 13, days: 3), hasParts(months: 1, days: 3));
      expect(Period(years: -2, months: 1, days: 3),
          hasParts(years: -1, months: -11, days: 3));
      expect(Period(years: -2, months: 13, days: 3),
          hasParts(months: -11, days: 3));
    });

    test('both negative', () {
      expect(Period(years: -1, months: -1, days: 3),
          hasParts(years: -1, months: -1, days: 3));
      expect(Period(years: -1, months: -13, days: 3),
          hasParts(years: -2, months: -1, days: 3));
    });
  });

  test('unary-', () {
    expect(-Period(years: 1, months: 2, days: 3),
        hasParts(years: -1, months: -2, days: -3));
  });

  group('toString()', () {
    test('zero', () {
      expect(Period().toString(), 'P0D');
    });

    test('positive', () {
      expect(Period(days: 1).toString(), 'P1D');
      expect(Period(months: 1).toString(), 'P1M');
      expect(Period(years: 1).toString(), 'P1Y');
      expect(Period(years: 1, months: 2, days: 3).toString(), 'P1Y2M3D');
    });

    test('negative', () {
      expect(Period(days: -1).toString(), 'P-1D');
      expect(Period(months: -1).toString(), 'P-1M');
      expect(Period(years: -1).toString(), 'P-1Y');
      expect(Period(years: -1, months: -2, days: -3).toString(), 'P-1Y-2M-3D');
    });
  });

  group('Equality and hashCode:', () {
    for (var c in <dynamic>[
      [
        Period(years: 1, months: 2, days: 3),
        Period(years: 1, months: 2, days: 3),
        true
      ],
      [Period(years: 1), Period(years: 1), true],
      [Period(months: 1), Period(months: 1), true],
      [Period(days: 1), Period(days: 1), true],
      [
        Period(years: 1, months: 2, days: 3),
        Period(years: 4, months: 5, days: 6),
        false
      ],
      [Period(years: 1), Period(years: 2), false],
      [Period(months: 1), Period(months: 2), false],
      [Period(days: 1), Period(days: 2), false],
    ]) {
      test('${c[0]} ==? ${c[1]}', () {
        expect(c[0] == c[1], c[2], reason: 'Equality');
        expect(c[0].hashCode == c[1].hashCode, c[2], reason: 'Hash codes');
      });
    }
  });
}
