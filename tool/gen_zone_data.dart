import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:tempo/timezone.dart';

import 'gen_zone_data/zone_info_reader.dart';
import 'gen_zone_data/zone_tab_reader.dart';

// make CFLAGS=-DHAVE_GETTEXT=0 TOPDIR="$(pwd)/install" TZDATA_TEXT=  install

const String zoneTabFilename = 'zone1970.tab';

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
    var zoneInfo = readZoneInfoRecords(zoneInfoDir);
    var zoneTab = readZoneTab1970(
        File(p.join(zoneInfoDir.path, zoneTabFilename)).readAsBytesSync());
    var zoneTabByCountry = byCountry(zoneTab);

    print(template(
        zoneInfo.toString(), zoneTab.toString(), zoneTabByCountry.toString()));
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

BuiltMap<String, ZoneTabRow> byCountry(BuiltList<ZoneTabRow> zoneTab) {
  var b = MapBuilder<String, ZoneTabRow>();
  for (var row in zoneTab) {
    for (var country in row.countries) {
      b[country] = row;
    }
  }
  return b.build();
}

String template(String zoneRules, String zoneTab, String zoneTabByCountry) =>
    DartFormatter().format("""// AUTOMATICALLY GENERATED: DO NOT EDIT

part of 'database.dart';

BuiltMap<String, ZoneRules> _zoneRules = '''$zoneRules''';

BuiltList<ZoneTabRow> _zoneTab = '''$zoneTab''';

BuiltListMultimap<String, ZoneTabRow> _zoneTabByCountry =
    '''$zoneTabByCountry''';
""");
