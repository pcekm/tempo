import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

void main() {
  test('us weekday numbers', () {
    expect(Weekday.sunday.us, 0);
    expect(Weekday.monday.us, 1);
    expect(Weekday.tuesday.us, 2);
    expect(Weekday.wednesday.us, 3);
    expect(Weekday.thursday.us, 4);
    expect(Weekday.friday.us, 5);
    expect(Weekday.saturday.us, 6);
  });

  test('iso weekday numbers', () {
    expect(Weekday.monday.iso, 1);
    expect(Weekday.tuesday.iso, 2);
    expect(Weekday.wednesday.iso, 3);
    expect(Weekday.thursday.iso, 4);
    expect(Weekday.friday.iso, 5);
    expect(Weekday.saturday.iso, 6);
    expect(Weekday.sunday.iso, 7);
  });
}
