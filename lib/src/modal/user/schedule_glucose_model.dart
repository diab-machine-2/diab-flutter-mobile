import 'package:meta/meta.dart';
@immutable
class ScheduleGlucoseModel {
  final ScheduleModel? monday;
  final ScheduleModel? tuesday;
  final ScheduleModel? wednesday;
  final ScheduleModel? thursday;
  final ScheduleModel? friday;
  final ScheduleModel? saturday;
  final ScheduleModel? sunday;

  ScheduleGlucoseModel(
      {required this.monday,
      required this.tuesday,
      required this.wednesday,
      required this.thursday,
      required this.friday,
      required this.saturday,
      required this.sunday});

  factory ScheduleGlucoseModel.fromJson(Map<String, dynamic> json) {
    return ScheduleGlucoseModel(
      monday: ScheduleModel.fromJson(json['monday']),
      tuesday: ScheduleModel.fromJson(json['tuesday']),
      wednesday: ScheduleModel.fromJson(json['wednesday']),
      thursday: ScheduleModel.fromJson(json['thursday']),
      friday: ScheduleModel.fromJson(json['friday']),
      saturday: ScheduleModel.fromJson(json['saturday']),
      sunday: ScheduleModel.fromJson(json['sunday']),
    );
  }

  static List<ScheduleGlucoseModel> toList(List<dynamic> items) {
    return items.map((item) => ScheduleGlucoseModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() => {
        'monday': monday!.toJson(),
        'tuesday': tuesday!.toJson(),
        'wednesday': wednesday!.toJson(),
        'thursday': thursday!.toJson(),
        'friday': friday!.toJson(),
        'saturday': saturday!.toJson(),
        'sunday': sunday!.toJson()
      };
}

class ScheduleModel {
  final bool? isBeforeBreakfast;
  final bool? isAfterBreakfast;
  final bool? isBeforeLunch;
  final bool? isAfterLunch;
  final bool? isBeforeDinner;
  final bool? isAfterDinner;
  final bool? isBeforeSleeping;

  ScheduleModel(
      {required this.isBeforeBreakfast,
      required this.isAfterBreakfast,
      required this.isBeforeLunch,
      required this.isAfterLunch,
      required this.isBeforeDinner,
      required this.isAfterDinner,
      required this.isBeforeSleeping});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
        isBeforeBreakfast: json['isBeforeBreakfast'],
        isAfterBreakfast: json['isAfterBreakfast'],
        isBeforeLunch: json['isBeforeLunch'],
        isAfterLunch: json['isAfterLunch'],
        isBeforeDinner: json['isBeforeDinner'],
        isAfterDinner: json['isAfterDinner'],
        isBeforeSleeping: json['isBeforeSleeping']);
  }

  static List<ScheduleModel> toList(List<dynamic> items) {
    return items.map((item) => ScheduleModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() => {
        'isBeforeBreakfast': isBeforeBreakfast,
        'isAfterBreakfast': isAfterBreakfast,
        'isBeforeLunch': isBeforeLunch,
        'isAfterLunch': isAfterLunch,
        'isBeforeDinner': isBeforeDinner,
        'isAfterDinner': isAfterDinner,
        'isBeforeSleeping': isBeforeSleeping
      };
}
