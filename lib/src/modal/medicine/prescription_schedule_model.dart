import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

/*----------------- LỊCH DÙNG THUỐC TAB -----------------*/
class PrescriptionsBySessionModel {
  final String id;
  final MedicineSession session;
  List<PrescriptionInSessionModel> prescriptions;

  PrescriptionsBySessionModel({
    required this.id,
    required this.session,
    required this.prescriptions,
  });
}

class PrescriptionInSessionModel {
  final String prescriptionId;
  final String prescriptionName;
  final DateTime time;
  final List<MedicationInSession> medications;
  final String? note;
  List<String>? photos;

  PrescriptionInSessionModel({
    required this.prescriptionId,
    required this.prescriptionName,
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

class MedicationInSession {
  final String id;
  final String medicineName;
  // e.g. 1 viên - Sau ăn
  final String dosage;
  // e.g. true ->
  bool isTaken;

  MedicationInSession({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.isTaken,
  });
}
