part of '../../tempo.dart';

/// A date and time at a fixed offset from UTC.
///
/// {@category absolute}
@immutable
class OffsetDateTime extends _RataDieDate
    with _TimeFields, _HasInstantImpl, _Formatting
    implements
        HasInstant,
        HasDateTime,
        _PeriodArithmetic<OffsetDateTime>,
        _ConvertibleDate {
  /// Constructs an `OffsetDateTime` from the individual components of a date
  /// and time.
  ///
  /// The date time will have the offset of the time zone specified in
  /// [defaultZoneId].
  ///
  /// {@macro astro_year}
  factory OffsetDateTime(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int nanosecond = 0]) {
    return ZonedDateTime(year, month, day, hour, minute, second, nanosecond)
        .asOffsetDateTime;
  }

  /// Constructs an `OffsetDateTime` from an offset and the individual
  /// components of the date and time.
  ///
  /// {@macro astro_year}
  const OffsetDateTime.withOffset(this.offset, int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int nanosecond = 0])
      : super(year, month, day, hour, minute, second, nanosecond);

  /// Constructs an `OffsetDateTime` from a `LocalDateTime`.
  ///
  /// {@template offset_unset}
  /// If [offset] is not specified, the result will have the offset from
  /// [defaultZoneId].
  /// {@endtemplate}
  factory OffsetDateTime.fromLocalDateTime(LocalDateTime dt,
      [ZoneOffset? offset]) {
    if (offset != null) {
      return OffsetDateTime._fromRataDieDate(dt, offset);
    } else {
      return ZonedDateTime._forLocal(dt).asOffsetDateTime;
    }
  }

  /// Constructs an `OffsetDateTime` with the current date and time.
  ///
  /// The resulting object will have the offset of [defaultZoneId].
  OffsetDateTime.now() : this.fromInstant(ZonedDateTime.now());

  /// Constructs an `OffsetDateTime` from a `DateTime`.
  ///
  /// This will have the same time zone offset as the `DateTime`.
  OffsetDateTime.fromDateTime(DateTime dateTime)
      : this.fromInstant(Instant.fromDateTime(dateTime),
            ZoneOffset.fromDuration(dateTime.timeZoneOffset));

  /// Constructs an `OffsetDateTime` from an `Instant`.
  ///
  /// {@macro offset_unset}
  OffsetDateTime.fromInstant(HasInstant hasInstant, [ZoneOffset? offset])
      : this._fromInstant(hasInstant.toInstant(),
            offset ?? _defaultOffset(hasInstant.toInstant()));

  OffsetDateTime._fromInstant(Instant instant, this.offset)
      : super._fromBigTime(instant._asRataDie + offset.asTimespan);

  /// Constructs an `OffsetDateTime` from an unix timestamp and a fixed offset
  /// from UTC.
  ///
  /// {@macro offset_unset}
  OffsetDateTime.fromUnix(Timespan unixTimestamp, [ZoneOffset? offset])
      : this.fromInstant(Instant.fromUnix(unixTimestamp), offset);

  OffsetDateTime._fromRataDieDate(super.rd, this.offset) : super._fromBigTime();

  /// Parses an `OffsetDateTime` from an ISO-8601 formatted string.
  ///
  /// The result will have the same offset as the input. If the input doesn't
  /// have an offset, the result will have an offset in the time zone specified
  /// by [defaultZoneId].
  ///
  /// ```dart
  /// OffsetDateTime.parse('2000-01-02T03:04+0545') ==
  ///   OffsetDateTime(ZoneOffset(5, 45), 2000, 1, 2, 3, 4);
  /// ```
  factory OffsetDateTime.parse(String isoString) {
    final parsed = _parseIso8160DateTime(isoString);
    if (parsed.offset != null) {
      return parsed.datetime.atOffset(parsed.offset!);
    } else {
      return parsed.datetime.inTimezone().asOffsetDateTime;
    }
  }

  /// The earliest supported datetime.
  static const OffsetDateTime minimum =
      OffsetDateTime.withOffset(ZoneOffset(0), -9999);

  /// The latest supported datetime.
  static const OffsetDateTime maximum = OffsetDateTime.withOffset(
      ZoneOffset(0), 9999, 12, 31, 23, 59, 59, 999999999);

  static ZoneOffset _defaultOffset(Instant instant) {
    return TimeZoneDatabase().rules[defaultZoneId]!.offsetFor(instant);
  }

  LocalDateTime get _dateTime => LocalDateTime._fromRataDieDate(this);
  Instant get _instant => Instant._fromRataDieDate(_add(-offset.asTimespan));

  /// The amount the time zone is offset from UTC.
  final ZoneOffset offset;

  @override
  Timespan get unixTimestamp => _instant.unixTimestamp;

  /// Converts this to a `LocalDateTime`.
  ///
  /// The result will have exactly the same year, month, day, etc. but will
  /// lack any time zone information.
  @override
  LocalDateTime toLocal() => _dateTime;

  @override
  Instant toInstant() => _instant;

  @override
  DateTime toDateTime() => DateTime.fromMicrosecondsSinceEpoch(
      _instant.unixTimestamp.inMicroseconds);

  /// Adds a `Timespan`.
  ///
  /// This increments the underlying [Instant] by exactly [timespan].
  /// See also [plusPeriod].
  ///
  /// ```dart
  /// var timespan = Timespan(hours: 1, minutes: 1);
  /// var dt = OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 12, 0);
  /// dt.plusTimespan(timespan) ==
  ///   OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 13, 1);
  /// ```
  OffsetDateTime plusTimespan(Timespan timespan) =>
      OffsetDateTime.fromInstant(_instant.plusTimespan(timespan), offset);

  /// Subtracts a `Timespan`.
  ///
  /// This decrements the underlying [Instant] by exactly [timespan].
  /// See also [minusPeriod].
  ///
  /// ```dart
  /// var timespan = Timespan(hours: 1, minutes: 1);
  /// var dt = OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 12, 0);
  /// dt.minusTimespan(timespan) ==
  ///   OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 11, 59);
  /// ```
  OffsetDateTime minusTimespan(Timespan timespan) =>
      OffsetDateTime.fromInstant(_instant.minusTimespan(timespan), offset);

  @override
  OffsetDateTime plusPeriod(Period period) =>
      OffsetDateTime.fromLocalDateTime(_dateTime.plusPeriod(period), offset);

  @override
  OffsetDateTime minusPeriod(Period period) =>
      OffsetDateTime.fromLocalDateTime(_dateTime.minusPeriod(period), offset);

  /// Formats this as an ISO 8601 date time with offset.
  ///
  /// ```dart
  /// OffsetDateTime(ZoneOffset(-7), 2023, 1, 2, 3, 4, 5).toString() ==
  ///   '2023-01-02T03:04:05-0700'
  /// ```
  @override
  String toString() => _iso8601DateTime(this, offset);

  /// The equality operator.
  ///
  /// Two [OffsetDateTime]s compare equal if and only if they have the same
  /// date _and_ the same offset. If you want to know if two represent the
  /// same moment in time, use [compareTo] or [toInstant].
  ///
  /// ```dart
  /// // Same moment in time; different zone offsets:
  /// var d1 = OffsetDateTime(ZoneOffset(0), 2023, 1, 1);
  /// var d2 = OffsetDateTime(ZoneOffset(-1), 2022, 12, 31, 23);
  ///
  /// d1 != d2;
  /// d1.compareTo(d2) == 0;
  /// d1.toInstant() == d2.toInstant();
  /// ```
  @override
  bool operator ==(Object other) =>
      other is OffsetDateTime &&
      _secondPart == other._secondPart &&
      _nanosecondPart == other._nanosecondPart &&
      offset == other.offset;

  @override
  int get hashCode => Object.hash(_secondPart, _nanosecondPart, offset);
}
