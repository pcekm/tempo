import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:tempo/src/timezone/zone_info.dart';
import 'package:tempo/timezone.dart';
import 'package:tempo/src/timezone/serializers.dart';

import 'gen_zone_data/zone_info_reader.dart';
import 'gen_zone_data/zone_tab_reader.dart';

const String zoneTabFilename = 'zone1970.tab';

const String outFile = 'lib/src/timezone/database.data.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/gen_zone_data.dart /path/to/tzdb');
    exit(1);
  }
  var path = args[0];

  var version = readVersion(path);
  stderr.writeln('Importing tzdb $version');

  var tempDir = Directory.systemTemp.createTempSync('tzdb');
  try {
    buildDatabase(path, tempDir);
    var zoneInfoDir = Directory(p.join(tempDir.path, 'usr/share/zoneinfo'));

    var zoneInfoRec = ZoneInfo((b) => b
      ..rules = readZoneInfoRecords(zoneInfoDir).toBuilder()
      ..zoneTab = readZoneTab1970(
              File(p.join(zoneInfoDir.path, zoneTabFilename)).readAsBytesSync())
          .toBuilder()
      ..zoneTabByCountry = byCountry(b.zoneTab.build()).toBuilder());

    File(outFile).writeAsStringSync(template(zoneInfoRec));
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Reads the version file from the tzdb directory.
String readVersion(String path) =>
    File(p.join(path, 'version')).readAsStringSync().trim();

/// Builds the zone database.
void buildDatabase(String dbPath, Directory tempDir) {
  var result = Process.runSync(
      'make',
      [
        'CFLAGS=-DHAVE_GETTEXT=0',
        'TOPDIR=${tempDir.path}',
        'TZDATA_TEXT=',
        'install'
      ],
      workingDirectory: dbPath);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}

BuiltMap<String, ZoneRules> readZoneInfoRecords(Directory zoneInfoDir) {
  var b = MapBuilder<String, ZoneRules>();
  for (var ent in zoneInfoDir.listSync(recursive: true)) {
    if (ent is! File || ent.path.endsWith('.tab')) {
      continue;
    }
    var zoneId = p.relative(ent.path, from: zoneInfoDir.path);
    b[zoneId] = ZoneInfoReader(ent.readAsBytesSync()).read();
  }
  return b.build();
}

BuiltListMultimap<String, ZoneTabRow> byCountry(BuiltList<ZoneTabRow> zoneTab) {
  var b = ListMultimapBuilder<String, ZoneTabRow>();
  for (var row in zoneTab) {
    for (var country in row.countries) {
      b.add(country, row);
    }
  }
  return b.build();
}

String template(ZoneInfo zoneInfoRec) {
  var zoneInfoJson = json.encode(serializers.serialize(zoneInfoRec));
  return DartFormatter().format("""// AUTOMATICALLY GENERATED: DO NOT EDIT

part of 'database.dart';

final ZoneInfo _zoneInfo = 
    serializers.deserialize(json.decode('''$zoneInfoJson''')) as ZoneInfo;
""");
}
