import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  test('toString()', () {
    expect(Period(days: 1).toString(), 'P1D');
    expect(Period(months: 1).toString(), 'P1M');
    expect(Period(years: 1).toString(), 'P1Y');
    expect(Period(years: 1, months: 2, days: 3).toString(), 'P1Y2M3D');
  });

  group('Equality and hashCode:', () {
    <dynamic>[
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
    ].forEach((c) {
      test('${c[0]} ==? ${c[1]}', () {
        expect(c[0] == c[1], c[2], reason: 'Equality');
        expect(c[0].hashCode == c[1].hashCode, c[2], reason: 'Hash codes');
      });
    });
  });
}
