

import 'daily_medicine_model.dart';

class MedicineScheduleModel {
  final int totalTargetDaily;
  final int totalTargetCompletedDaily;
  final int totalTargetWeekly;
  final int totalTargetCompletedWeekly;
  final List<DailyMedicineModel> daily;
  final List<dynamic> weekly;

  MedicineScheduleModel({
    required this.totalTargetDaily,
    required this.totalTargetCompletedDaily,
    required this.totalTargetWeekly,
    required this.totalTargetCompletedWeekly,
    required this.daily,
    required this.weekly,
  });

  factory MedicineScheduleModel.fromJson(Map<String, dynamic> json) {
    return MedicineScheduleModel(
      totalTargetDaily: json['totalTargetDaily'] ?? 0,
      totalTargetCompletedDaily: json['totalTargetCompletedDaily'] ?? 0,
      totalTargetWeekly: json['totalTargetWeekly'] ?? 0,
      totalTargetCompletedWeekly: json['totalTargetCompletedWeekly'] ?? 0,
      daily: (json['daily'] as List<dynamic>?)
          ?.map((e) => DailyMedicineModel.fromJson(e))
          .toList() ??
          [],
      weekly: json['weekly'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTargetDaily': totalTargetDaily,
      'totalTargetCompletedDaily': totalTargetCompletedDaily,
      'totalTargetWeekly': totalTargetWeekly,
      'totalTargetCompletedWeekly': totalTargetCompletedWeekly,
      'daily': daily.map((e) => e.toJson()).toList(),
      'weekly': weekly,
    };
  }
}
