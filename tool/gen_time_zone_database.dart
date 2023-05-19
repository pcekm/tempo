import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:tempo/src/timezone/serializers.dart';
import 'package:tempo/timezone.dart';

import 'gen_time_zone_database/zone_info_reader.dart';
import 'gen_time_zone_database/zone_tab_reader.dart';

const String zoneTabFilename = 'zone1970.tab';

const String libraryName = 'time_zone_database';

const String outFile = 'lib/src/timezone/$libraryName.data.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln(
        'Usage: dart run tool/gen_time_zone_database.dart /path/to/tzdb');
    exit(1);
  }
  var path = args[0];

  var version = readVersion(path);
  stderr.writeln('Importing tzdb $version');

  var tempDir = Directory.systemTemp.createTempSync('tzdb');
  try {
    buildDatabase(path, tempDir);
    var zoneInfoDir = Directory(p.join(tempDir.path, 'usr/share/zoneinfo'));

    var zoneInfoRec = TimeZoneDatabase.build((b) => b
      ..version = version
      ..rules = readZoneInfoRecords(zoneInfoDir).toBuilder()
      ..descriptions = readZoneTab1970(
              File(p.join(zoneInfoDir.path, zoneTabFilename)).readAsBytesSync())
          .toBuilder()
      ..descriptionsByCountry = byCountry(b.descriptions.build()).toBuilder());

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

BuiltListMultimap<String, ZoneDescription> byCountry(
    BuiltList<ZoneDescription> zoneTab) {
  var b = ListMultimapBuilder<String, ZoneDescription>();
  for (var row in zoneTab) {
    for (var country in row.countries) {
      b.add(country, row);
    }
  }
  return b.build();
}

String template(TimeZoneDatabase zoneInfoRec) {
  var zoneInfoJson = json.encode(serializers.serialize(zoneInfoRec));
  return DartFormatter().format("""// AUTOMATICALLY GENERATED: DO NOT EDIT

part of '$libraryName.dart';

final TimeZoneDatabase _defaultTimeZoneDatabase = 
    serializers.deserialize(json.decode('''$zoneInfoJson'''))
    as TimeZoneDatabase;
""");
}
