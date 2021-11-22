extension DateTimeUntil on DateTime {
  DateTime copy(DateTime dateTime) => DateTime(
        this.year,
        this.month,
        this.day,
        this.hour,
        this.minute,
      );

  DateTime copyDate(DateTime dateTime) => DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        this.hour,
        this.minute,
      );

  DateTime copyTime({int? hour, int? minute}) => DateTime(
        this.year,
        this.month,
        this.day,
        hour ?? this.hour,
        minute ?? this.minute,
      );

  DateTime goToBeginOfTheDay() => this.copyTime(hour: 0, minute: 0);

  String get dayInWeek {
    if (this.weekday == 7) return 'CN';
    return 'T${this.weekday + 1}';
  }
}
