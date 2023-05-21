import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

import '../../example/example.dart';

void main() {
  test('forEachDay', () {
    var days = <LocalDate>[];
    forEachDay(LocalDate(2000), LocalDate(2000, 1, 5), (d) {
      days.add(d);
    });
    expect(days, [
      LocalDate(2000, 1, 1),
      LocalDate(2000, 1, 2),
      LocalDate(2000, 1, 3),
      LocalDate(2000, 1, 4)
    ]);
  });

  test('calendar', () {
    final want = 'Sun Mon Tue Wed Thu Fri Sat\n'
        '  1   2   3   4   5   6   7\n'
        '  8   9  10  11  12  13  14\n'
        ' 15  16  17  18  19  20  21\n'
        ' 22  23  24  25  26  27  28\n'
        ' 29  30  31\n';
    expect(() => printCalendar(2023, 10), prints(want));
  });
}
