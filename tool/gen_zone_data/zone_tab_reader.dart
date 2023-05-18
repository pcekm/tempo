import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';

import 'package:tempo/timezone.dart';

final _latLongRe =
    RegExp(r'^([+-])(\d{2})(\d{2})(\d{2})?([+-])(\d{3})(\d{2})(\d{2})?$');

/// Reads 'zone1970.tab' file.
BuiltList<ZoneTabRow> readZoneTab1970(Uint8List contents) {
  var lines = LineSplitter()
      .convert(utf8.decode(contents))
      .where((line) => line.trim().isNotEmpty && !line.startsWith('#'));
  var zoneDescriptions = lines.map((line) => _parseLine(line));
  return BuiltList.build((b) => b.addAll(zoneDescriptions));
}

ZoneTabRow _parseLine(String line) {
  var fields = line.split('\t');
  var latLong = _latLongRe.firstMatch(fields[1]);
  return ZoneTabRow((b) => b
    ..zoneId = fields[2]
    ..countries.addAll(fields[0].split(','))
    ..latitude = _dmsToDouble(
        latLong!.group(1), latLong.group(2), latLong.group(3), latLong.group(4))
    ..longitude = _dmsToDouble(
        latLong.group(5), latLong.group(6), latLong.group(7), latLong.group(8))
    ..comments = fields.length >= 4 ? fields[3] : '');
}

double _dmsToDouble(
        String? sign, String? degrees, String? minutes, String? seconds) =>
    (sign == '-' ? -1 : 1) *
    (int.parse(degrees ?? '0') +
        int.parse(minutes ?? '0') / 60 +
        int.parse(seconds ?? '0') / 3600);
