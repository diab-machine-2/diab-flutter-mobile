import 'completion_status.dart';

const timeStep = Duration(days: 1);

class TimeData {
  TimeData({
    required this.startDate,
    required this.endDate,
  }) {
    DateTime dateTime = firstDayOfTheFirstWeek;
    final DateTime theLastDay = lastDayOfTheLastWeek;
    List<DateTime> singleWeek = [];
    while (dateTime.isBefore(theLastDay)) {
      singleWeek.add(dateTime);
      if (dateTime.weekday == DateTime.sunday) {
        weekList.add(WeekData(dayList: singleWeek));
        singleWeek = [];
      }
      dateTime = dateTime.add(timeStep);
    }
  }

  final DateTime startDate;
  final DateTime endDate;
  final List<WeekData> weekList = [];
  int currentWeekIndex = 0;

  WeekData get currentWeek => weekList[currentWeekIndex];

  DateTime get firstDayOfTheFirstWeek =>
      startDate.subtract(Duration(days: startDate.weekday - 1));

  DateTime get lastDayOfTheLastWeek =>
      endDate.add(Duration(days: DateTime.daysPerWeek - endDate.weekday));
}

class WeekData {
  WeekData({
    required this.dayList,
    this.status = CompletionStatus.not_completed
  });
  final List<DateTime> dayList;
  CompletionStatus status;
}
