import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

void main() {
  test('default is UTC', () {
    expect(defaultZoneId, 'UTC');
  });

  test('change default', () {
    defaultZoneId = 'America/Los_Angeles';
    expect(defaultZoneId, 'America/Los_Angeles');
  });

  test('throws on invalid value', () {
    expect(
        () => defaultZoneId = 'Europe/Genovia', throwsA(isA<ArgumentError>()));
  });
}
