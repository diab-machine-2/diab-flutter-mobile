import 'package:medical/src/utils/extention.dart';

class CongratulationState {
  CongratulationState(
      {required this.currentDate,
      this.dailyShowed = false,
      this.weeklyShowed = false});
  DateTime currentDate;
  bool dailyShowed;
  bool weeklyShowed;

  bool get shouldShowWeekPopup =>
      currentDate.isSameDayWith(DateTime.now()) && !weeklyShowed;
  bool get shouldShowDailyPopup =>
      currentDate.isSameDayWith(DateTime.now()) && !dailyShowed;
}
