part of '../../zonedb.dart';

ZoneInfoRecord? lookupZoneInfo(String id) {
  var file = _zoneInfoData.findFile('zoneinfo/${_escapeId(id)}');
  if (file == null) {
    return null;
  }
  return ZoneInfoReader(_humanizeId(id), file.content).read();
}

// Normalizes, converts spaces to underscores in a zone id.
String _escapeId(String name) =>
    name.trim().replaceAll(RegExp(r'(\s|_)+'), '_');

// Normalizes and humanizes a zone id.
String _humanizeId(String name) =>
    name.trim().replaceAll(RegExp(r'(\s|_)+'), ' ');
