import 'package:tuple/tuple.dart';

/// Converts Julian Day to Year, Month, Day.
Tuple3<int, int, int> julianDaysToGregorian(int julianDays) {
  // See https://en.wikipedia.org/wiki/Julian_day
  const int y = 4716;
  const int j = 1401;
  const int m = 2;
  const int n = 12;
  const int r = 4;
  const int p = 1461;
  const int v = 3;
  const int u = 5;
  const int s = 153;
  const int w = 2;
  const int B = 274277;
  const int C = -38;

  final int f =
      julianDays + j + (((4 * julianDays + B) ~/ 146097) * 3) ~/ 4 + C;
  final int e = r * f + v;
  final int g = (e % p) ~/ r;
  final int h = u * g + w;

  final int D = (h % s) ~/ u + 1;
  final int M = (h ~/ s + m) % n + 1;
  final int Y = e ~/ p - y + (n + m - M) ~/ n;

  return Tuple3<int, int, int>(Y, M, D);
}
