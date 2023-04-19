import 'package:goodtime/src/util.dart';
import 'package:test/test.dart';

// Equality matcher that looks for
void main() {
  test('checkLeapYear()', () {
    expect(checkLeapYear(2023), false);
    expect(checkLeapYear(2024), true); // modulo 4 rule
    expect(checkLeapYear(1900), false); // modulo 100 rule
    expect(checkLeapYear(2000), true); // modulo 400 rule
  });

  test('daysInMonth()', () {
    expect(daysInMonth(2023, 1), 31);
    expect(daysInMonth(2023, 2), 28);
    expect(daysInMonth(2024, 2), 29);
    expect(daysInMonth(2024, 12), 31);
  });
}
