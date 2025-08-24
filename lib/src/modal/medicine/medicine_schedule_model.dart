import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

import 'prescription_model.dart';

enum PrescriptionStatus { active, inactive }

class MedicineScheduleModel {
  final List<PrescriptionModel> activePrescriptions;
  final List<PrescriptionModel> inactivePrescriptions;

  MedicineScheduleModel({
    required this.activePrescriptions,
    required this.inactivePrescriptions,
  });

  factory MedicineScheduleModel.fromJson(Map<String, dynamic> json) {
    return MedicineScheduleModel(
      activePrescriptions: (json['activePrescriptions'] as List)
          .map((e) => PrescriptionModel.fromJson(e))
          .toList(),
      inactivePrescriptions: (json['inactivePrescriptions'] as List)
          .map((e) => PrescriptionModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'activePrescriptions':
    activePrescriptions.map((e) => e.toJson()).toList(),
    'inactivePrescriptions':
    inactivePrescriptions.map((e) => e.toJson()).toList(),
  };
}

/*----------------- LỊCH DÙNG THUỐC TAB -----------------*/
class PrescriptionBySessionModel {
  final String id;
  final MedicineSession session;
  String name;
  final DateTime time;
  final List<MedicationInSession> medications;
  final String? note;
  List<String>? photos;

  PrescriptionBySessionModel({
    required this.id,
    required this.session,
    required this.name,
    required this.time,
    required this.medications,
    this.note,
    this.photos,
  });
}

enum MedicineSession {
  MORNING,
  NOON,
  AFTERNOON,
  EVENING;

  @override
  String toString() {
    switch (this) {
      case MedicineSession.MORNING:
        return R.string.the_morning.tr();
      case MedicineSession.NOON:
        return R.string.the_noon.tr();
      case MedicineSession.AFTERNOON:
        return R.string.the_afternoon.tr();
      case MedicineSession.EVENING:
        return R.string.the_evening.tr();
    }
  }
}

/**
 * A medicine with its dosage and whether it has been taken or not.
 * This item is used in [PrescriptionBySessionModel].
 */
class MedicationInSession {
  final String medicineName;
  // e.g. 1 viên - Sau ăn
  final String dosage;
  // e.g. true ->
  final bool isTaken;

  MedicationInSession({
    required this.medicineName,
    required this.dosage,
    required this.isTaken,
  });
}
