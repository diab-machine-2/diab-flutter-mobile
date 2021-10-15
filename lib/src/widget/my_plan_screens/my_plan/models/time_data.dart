const timeStep = Duration(days: 1);

class TimeData {
  TimeData({
    required this.startDate,
    required this.endDate,
  }) {
    DateTime dateTime = firstDayOfTheFirstWeek;
    final DateTime theLastDay = lastDayOfTheLastWeek;
    List<DateTime> singleWeek = [];
    while(dateTime.isBefore(theLastDay)) {
      singleWeek.add(dateTime);
      if (dateTime.weekday == DateTime.sunday) {
        weekList.add(singleWeek);
        singleWeek = [];
      }
      dateTime = dateTime.add(timeStep);
    }
  }

  final DateTime startDate;
  final DateTime endDate;
  final List<List<DateTime>> weekList = [];
  int currentWeekIndex = 0;

  List<DateTime> get currentWeek => weekList[currentWeekIndex];

  DateTime get firstDayOfTheFirstWeek =>
      startDate.subtract(Duration(days: startDate.weekday - 1));

  DateTime get lastDayOfTheLastWeek =>
      endDate.add(Duration(days: DateTime.daysPerWeek - endDate.weekday));
}
