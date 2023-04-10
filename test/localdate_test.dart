import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var d = LocalDate(2000, 1, 2);
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
    });

    test('fromDateTime()', () {
      var d = LocalDate.fromDateTime(DateTime(2000, 1, 2));
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
    });

    test('now() smoke test', () {
      var d = LocalDate.now();
      expect(d.year, greaterThanOrEqualTo(2023));
    });
  });

  group('Comparison operator', () {
    test('== (and hash equality)', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(2000, 1, 2);
      expect(d1, d2);
      expect(d1.hashCode, d2.hashCode, reason: 'Hash mismatch');
    });

    test('!= (and hash inequality)', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(20001, 1, 3);
      expect(d1, isNot(equals(d2)));
      expect(d1.hashCode, isNot(equals(d2.hashCode)), reason: 'Hashes equal');
    });

    test('>', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(2000, 1, 1);
      expect(d1 > d2, true);
      expect(d1 > d1, false);
    });

    test('>=', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(2000, 1, 1);
      expect(d1 >= d2, true);
      expect(d1 >= d1, true);
    });

    test('<', () {
      var d1 = LocalDate(2000, 1, 1);
      var d2 = LocalDate(2000, 1, 2);
      expect(d1 < d2, true);
      expect(d1 < d1, false);
    });

    test('<=', () {
      var d1 = LocalDate(2000, 1, 1);
      var d2 = LocalDate(2000, 1, 2);
      expect(d1 <= d2, true);
      expect(d1 <= d1, true);
    });
  });

  test('weekday', () {
    // A date which will live in infamy.
    expect(LocalDate(1941, 12, 7).weekday, Weekday.sunday);
    expect(LocalDate(2023, 4, 10).weekday, Weekday.monday);
    expect(LocalDate(2023, 4, 11).weekday, Weekday.tuesday);
    expect(LocalDate(2023, 4, 12).weekday, Weekday.wednesday);
    expect(LocalDate(2023, 4, 13).weekday, Weekday.thursday);
    expect(LocalDate(2023, 4, 14).weekday, Weekday.friday);
    expect(LocalDate(2023, 4, 15).weekday, Weekday.saturday);
    expect(LocalDate(2023, 4, 16).weekday, Weekday.sunday);
  });

  test('toString()', () {
    expect(LocalDate(2023, 4, 10).toString(), '2023-04-10');
    expect(LocalDate(1).toString(), '0001-01-01');
    expect(LocalDate(0).toString(), '+0000-01-01'); // 1 BC
    expect(LocalDate(-2000).toString(), '-2000-01-01');
    expect(LocalDate(9999).toString(), '9999-01-01');
    expect(LocalDate(10000).toString(), '+10000-01-01');
  });

  test('minimum and maximum', () {
    expect(LocalDate.minimum.toString(), '-4713-11-24');
    expect(LocalDate.safeMaximum.toString(), '+24660873948184-12-03');
  });

  test('ordinalDay', () {
    expect(LocalDate(2023, 4, 10).ordinalDay, 100);
    expect(LocalDate(2023, 1, 1).ordinalDay, 1);
    expect(LocalDate(2023, 12, 31).ordinalDay, 365);
  });
}
