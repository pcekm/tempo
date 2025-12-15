import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

Matcher isWeekday(int us, int iso) => isA<Weekday>()
    .having((w) => w.us, 'us', us)
    .having((w) => w.iso, 'iso', iso);

void main() {
  test('weekday numbers', () {
    expect(Weekday.sunday, isWeekday(0, 7));
    expect(Weekday.monday, isWeekday(1, 1));
    expect(Weekday.tuesday, isWeekday(2, 2));
    expect(Weekday.wednesday, isWeekday(3, 3));
    expect(Weekday.thursday, isWeekday(4, 4));
    expect(Weekday.friday, isWeekday(5, 5));
    expect(Weekday.saturday, isWeekday(6, 6));
  });
}
