import 'dart:convert';
import 'dart:typed_data';

import 'package:tempo/timezone.dart';
import 'package:test/test.dart';

import '../../tool/gen_zone_data/zone_tab_reader.dart';

const String contents = '# comment\n'
    '# another comment\n'
    '#country-\n'
    '#codes\tcoordinates\tTZ\tcomments\n'
    'AD\t+4230+00131\tEurope/Andorra\n'
    'AE,OM,RE,SC,TF\t+2518+05518\tAsia/Dubai\tCrozet, Scattered Is\n'
    'AM\t+4011+04430\tAsia/Yerevan\n'
    'AQ\t-6448-06406\tAntarctica/Palmer\tPalmer\n'
    'AQ\t-720041+0023206\tAntarctica/Troll\tTroll\n'
    '# comment\n'
    'ZA,LS,SZ\t-2615+02800\tAfrica/Johannesburg\n'
    '  \n'
    '# more comments\n';

void main() {
  test('readZoneTab1970', () {
    var lines = readZoneTab1970(Uint8List.fromList(utf8.encode(contents)));
    expect(
        lines,
        containsOnce(ZoneTabRow((b) => b
          ..countries.add('AD')
          ..latitude = 42.5
          ..longitude = 1 + 31 / 60
          ..zoneId = 'Europe/Andorra'
          ..comments = '')));
    expect(
        lines,
        containsOnce(ZoneTabRow((b) => b
          ..countries.addAll(['AE', 'OM', 'RE', 'SC', 'TF'])
          ..latitude = 25 + 18 / 60
          ..longitude = 55 + 18 / 60
          ..zoneId = 'Asia/Dubai'
          ..comments = 'Crozet, Scattered Is')));
    // https://youtu.be/oynJcSnLSI4:
    expect(
        lines,
        containsOnce(ZoneTabRow((b) => b
          ..countries.addAll(['AQ'])
          ..latitude = -72 - 41 / 3600
          ..longitude = 2 + 32 / 60 + 6 / 3600
          ..zoneId = 'Antarctica/Troll'
          ..comments = 'Troll')));
  });
}
