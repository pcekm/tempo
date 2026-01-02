part of '../../tempo.dart';

/// Represents a single instant in time as a [Timespan] since
/// January 1, 1970 UTC.
///
/// In general, this will be more useful when converted to an
/// [OffsetDateTime] or a [ZonedDateTime].
///
/// ```dart
/// var instant = Instant.now();
/// instant.atOffset(ZoneOffset(-7));
/// instant.inTimezone('America/Phoenix');
/// ```
///
/// {@category absolute}
@immutable
class Instant with _HasInstantImpl implements HasInstant, _ConvertibleDate {
  /// Creates an instant given a time since midnight, January 1, 1970 UTC.
  ///
  /// The Unix timestamp can be provided in any units supported by [Timespan].
  /// These examples all produce the same `Instant`:
  ///
  /// ```dart
  /// Instant.fromUnix(Timespan(seconds: 1));
  /// Instant.fromUnix(Timespan(milliseconds: 1000));
  /// Instant.fromUnix(Timespan(nanoseconds: 1000000000));
  /// ```
  const Instant.fromUnix(this.unixTimestamp);

  /// Parses an `Instant` from an ISO-8601 formatted string.
  ///
  /// Assumes strings without a zone offset are UTC.
  factory Instant.parse(String isoString) {
    final parsed = _parseIso8160DateTime(isoString);
    if (parsed.offset == null) {
      return parsed.datetime.toInstant();
    } else {
      return parsed.datetime.atOffset(parsed.offset!).toInstant();
    }
  }

  /// Creates an instant from a [DateTime].
  ///
  /// {@template datetime_precision}
  /// The precision depends on Dart's [DateTime] object which varies by Dart
  /// version and platform.
  ///
  /// | Dart Version | Platform | Precision   |
  /// |--------------|----------|-------------|
  /// | ≥ 3.5.0      | All      | Microsecond |
  /// | < 3.5.0      | Native   | Microsecond |
  /// | < 3.5.0      | Web      | Millisecond |
  /// {@endtemplate}
  Instant.fromDateTime(DateTime dateTime)
      : this.fromUnix(Timespan(microseconds: dateTime.microsecondsSinceEpoch));

  /// Creates an instant for the current time.
  ///
  /// {@macro datetime_precision}
  Instant.now() : this.fromDateTime(clock.now());

  Instant._fromRataDieDate(_BigTime rd)
      : unixTimestamp =
            Timespan(seconds: rd._secondPart, nanoseconds: rd._nanosecondPart) -
                _rataDieOffset;

  /// The earliest supported instant.
  ///
  /// This translates to midnight, -9999-01-01.
  static const Instant minimum =
      Instant.fromUnix(Timespan(seconds: -377705116800));

  /// The latest supported instant.
  ///
  /// This translates to 9999-12-31 at 23:59:59.999999999.
  static const Instant maximum =
      Instant.fromUnix(Timespan(seconds: 253402300799, nanoseconds: 999999999));

  /// The offset between Rata Die and Unix.
  static const Timespan _rataDieOffset = Timespan(days: 719163);

  @override
  final Timespan unixTimestamp;

  @override
  DateTime toDateTime() =>
      DateTime.fromMicrosecondsSinceEpoch(unixTimestamp.inMicroseconds);

  /// Returns this unchanged.
  @override
  Instant toInstant() => this;

  @override
  LocalDateTime toLocal() => LocalDateTime._fromRataDieDate(_asRataDie);

  /// Adds a [Timespan].
  Instant plusTimespan(Timespan t) => Instant.fromUnix(unixTimestamp + t);

  /// Subtracts a [Timespan].
  Instant minusTimespan(Timespan t) => Instant.fromUnix(unixTimestamp - t);

  Timespan get _asRataDie => unixTimestamp + _rataDieOffset;

  /// Formats this as an ISO 8601 timestamp.
  ///
  /// For example, `2000-01-02T03:04:05.123456789Z`.
  @override
  String toString() {
    var dateTime = LocalDateTime._fromRataDieDate(_asRataDie);
    return _iso8601DateTime(dateTime, ZoneOffset(0), true);
  }

  @override
  bool operator ==(Object other) =>
      (other is Instant) && unixTimestamp == other.unixTimestamp;

  @override
  int get hashCode => unixTimestamp.hashCode;
}
