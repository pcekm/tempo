class LocalTime {
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final int microsecond;

  const LocalTime(this.hour,
      [this.minute = 0,
      this.second = 0,
      this.millisecond = 0,
      this.microsecond = 0]);
}
