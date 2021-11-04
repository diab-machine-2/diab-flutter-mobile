extension DateTimeUntil on DateTime {
  DateTime copyDate(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      this.hour,
      this.minute,
    );
  }

  DateTime copyTime({int? hour, int? minute}) {
    return DateTime(
      this.year,
      this.month,
      this.day,
      hour ?? this.hour,
      minute ?? this.minute,
    );
  }

  DateTime goToBeginOfTheDay() {
    return this.copyTime(hour: 0, minute: 0);
  }

  String get dayInWeek {
    if (this.weekday == 7) return 'CN';
    return 'T${this.weekday + 1}';
  }
}
