part of '../../tempo.dart';

abstract mixin class _Formatting implements _ConvertibleDate {
  /// Formats this object using the given format.
  ///
  /// Since different objects convert to [DateTime] differently, using this
  /// method instead of calling [DateFormat.format] directly can avoid some
  /// surprising results.
  String format(DateFormat format) => format.format(toLocal().toDateTime());
}
