extension DateTimeExtend on DateTime {
  String get dayInWeek {
    if (this.weekday == 7) return 'CN';
    return 'T${this.weekday + 1}';
  }
}