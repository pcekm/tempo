part of '../../zoneinfo.dart';

class TimeZone {
  final ZoneOffset offset;
  final String designation;
  final bool isDst;

  TimeZone(this.offset, this.designation, this.isDst);
}

class _LocalTimeTypeBlock {
  final ZoneOffset utOffset;
  final bool isDst;
  final int index;

  _LocalTimeTypeBlock(this.utOffset, this.isDst, this.index);

  @override
  String toString() => [utOffset, isDst, index].toString();

  @override
  bool operator ==(Object other) =>
      other is _LocalTimeTypeBlock &&
      utOffset == other.utOffset &&
      isDst == other.isDst &&
      index == other.index;

  @override
  int get hashCode => Object.hash(utOffset, isDst, index);
}

class ZoneInfoRecord {
  final String name;

  // These two lists should be the same length according to the spec.
  final List<Instant> _transitionTimes;
  final List<int> _transitionTypes;

  final List<_LocalTimeTypeBlock> _localTimeTypes;

  final Map<int, String> _designations;

  final PosixTz _posixTz;

  ZoneInfoRecord(
    this.name,
    this._transitionTimes,
    this._transitionTypes,
    this._localTimeTypes,
    this._designations,
    this._posixTz,
  );

  TimeZone timeZoneFor(HasInstant instant) {
    var i = lowerBound(_transitionTimes, instant);
    if (i == _transitionTimes.length) {
      return _posixTz.timeZoneFor(instant);
    }
    var timeType = _localTimeTypes[_transitionTypes[i]];
    return TimeZone(
      timeType.utOffset,
      _designations[timeType.index]!,
      timeType.isDst,
    );
  }

  @override
  String toString() => 'TimeZone($name)';
}
