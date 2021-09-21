import 'package:meta/meta.dart';

class ScheduleGlucoseTimeModel {
  final int? beforeEat;
  final int? afterEat;
  final int? beforeSleeping;
  final int? glucoseUnit;

  ScheduleGlucoseTimeModel(
      {required this.beforeEat,
      required this.afterEat,
      required this.beforeSleeping,
      required this.glucoseUnit});

  factory ScheduleGlucoseTimeModel.fromJson(Map<String, dynamic> json) {
    return ScheduleGlucoseTimeModel(
        beforeEat: json['beforeEat'],
        afterEat: json['afterEat'],
        beforeSleeping: json['beforeSleeping'],
        glucoseUnit: json['glucoseUnit']);
  }

  static List<ScheduleGlucoseTimeModel> toList(List<dynamic> items) {
    return items
        .map((item) => ScheduleGlucoseTimeModel.fromJson(item))
        .toList();
  }
}
