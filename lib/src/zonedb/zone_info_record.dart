part of '../zonedb.dart';

/// Contains a single zoneinfo record.
///
/// The zoneinfo format is described in the
/// [tzfile(5)](https://linux.die.net/man/5/tzfile) manpage, and in
/// [RFC 8536](https://www.rfc-editor.org/rfc/rfc8536.html).
abstract class ZoneInfoRecord
    implements Built<ZoneInfoRecord, ZoneInfoRecordBuilder> {
  static Serializer<ZoneInfoRecord> get serializer =>
      _$zoneInfoRecordSerializer;
  String get name;

  // These two lists should be the same length according to the spec.
  List<Instant> get transitionTimes;
  List<int> get transitionTypes;

  List<LocalTimeTypeBlock> get localTimeTypes;

  Map<int, String> get designations;

  PosixTz get posixTz;

  /// Returns the time offset and designation for an [Instant].
  TimeZone timeZoneFor(HasInstant instant) {
    var i = lowerBound(transitionTimes, instant);
    if (i == 0 || i == transitionTimes.length) {
      return posixTz.timeZoneFor(instant);
    }
    var timeType = localTimeTypes[transitionTypes[i - 1]];
    return TimeZone(
      timeType.utOffset,
      designations[timeType.index]!,
      timeType.isDst,
    );
  }

  ZoneInfoRecord._();
  factory ZoneInfoRecord([void Function(ZoneInfoRecordBuilder) updates]) =
      _$ZoneInfoRecord;
}
