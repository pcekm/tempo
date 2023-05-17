import 'dart:io';
import 'package:tempo/tempo.dart';
import 'package:tempo/src/zonedb.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

// make CFLAGS=-DHAVE_GETTEXT=0 TOPDIR="$(pwd)/install" TZDATA_TEXT=  install

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
    var records = readZoneInfoRecords(zoneInfoDir);
    print(records);
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

Map<String, ZoneInfoRecord> readZoneInfoRecords(Directory zoneInfoDir) {
  var records = <String, ZoneInfoRecord>{};
  for (var ent in zoneInfoDir.listSync(recursive: true)) {
    if (ent is! File || ent.path.endsWith('.tab')) {
      continue;
    }
    var zoneId = p.relative(ent.path, from: zoneInfoDir.path);
    records[zoneId] = ZoneInfoReader(zoneId, ent.readAsBytesSync()).read();
  }
  return records;
}
