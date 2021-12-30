import 'package:medical/src/utils/extention.dart';

class CongratulationState {
  CongratulationState(
      {required this.currentDate,
      this.dailyShowed = false,
      this.weeklyShowed = false});
  DateTime currentDate;
  bool dailyShowed;
  bool weeklyShowed;

  void checkDate() {
    if (!currentDate.isSameDayWith(DateTime.now())) {
      currentDate = DateTime.now();
      dailyShowed = false;
      weeklyShowed = false;
    }
  }
}
