import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  group('parse()', () {
    test('simple', () {
      expect(Period.parse('P0Y'), Period());
      expect(Period.parse('P1Y'), Period(years: 1));
      expect(Period.parse('P-1Y'), Period(years: -1));
      expect(Period.parse('P0M'), Period());
      expect(Period.parse('P1M'), Period(months: 1));
      expect(Period.parse('P-1M'), Period(months: -1));
      expect(Period.parse('P0W'), Period());
      expect(Period.parse('P1W'), Period(days: 7));
      expect(Period.parse('P-1W'), Period(days: -7));
      expect(Period.parse('P0D'), Period());
      expect(Period.parse('P1D'), Period(days: 1));
      expect(Period.parse('P-1D'), Period(days: -1));
    });

    test('complex', () {
      expect(Period.parse('P1Y2M3W4D'), Period(years: 1, months: 2, days: 25));
      expect(Period.parse('P-1Y-2M-3W-4D'),
          -Period(years: 1, months: 2, days: 25));
    });

    test('ignores hours, minutes and seconds', () {
      expect(Period.parse('PT1M'), Period());
      expect(Period.parse('PT-1H1.1M1,23S'), Period());
      expect(Period.parse('P1YT-1H1.1M1,23S'), Period(years: 1));
    });
  });

  test('normalized', () {
    expect(Period(years: 1, months: 13, days: 3).normalized(),
        Period(years: 2, months: 1, days: 3));
    expect(Period(days: 35).normalized(), Period(days: 35));
    expect(Period(months: 11).normalized(), Period(months: 11));
  });

  test('unary-', () {
    expect(-Period(years: 1, months: 2, days: 3),
        Period(years: -1, months: -2, days: -3));
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
