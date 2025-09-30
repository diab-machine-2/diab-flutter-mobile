import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

import 'daily_medicine_model.dart';

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

  static List<PrescriptionsBySessionModel>  fromDailyList(List<DailyMedicineModel> dailyList) {
    // Nhóm theo session
    final Map<MedicineSession, List<DailyMedicineModel>> bySession = {};

    for (var daily in dailyList) {
      // map executeDayTimes -> MedicineSession
      MedicineSession session;
      switch (daily.executeDayTimes) {
        case 1:
          session = MedicineSession.MORNING;
          break;
        case 2:
          session = MedicineSession.NOON;
          break;
        case 3:
          session = MedicineSession.AFTERNOON;
          break;
        case 4:
        default:
          session = MedicineSession.EVENING;
          break;
      }

      bySession.putIfAbsent(session, () => []).add(daily);
    }

    // Convert thành List<PrescriptionsBySessionModel>
    return bySession.entries.map((sessionEntry) {
      final session = sessionEntry.key;
      final sessionDailies = sessionEntry.value;

      // Nhóm tiếp theo prescriptionId
      final Map<String, List<DailyMedicineModel>> byPrescription = {};
      for (var daily in sessionDailies) {
        final presId = daily.prescriptionId ?? "unknown";
        byPrescription.putIfAbsent(presId, () => []).add(daily);
      }

      final prescriptions = byPrescription.entries.map((presEntry) {
        final presId = presEntry.key;
        final presDailies = presEntry.value;

        // Lấy prescriptionName và note từ daily (chung 1 đơn thuốc)
        final presName = presDailies.first.prescriptionName;
        final note = presDailies.first.description;
        final time = DateTime.fromMillisecondsSinceEpoch(presDailies.first.appointmentDate * 1000);

        // Convert list DailyMedicineModel -> MedicationInSession
        final medications = presDailies.map((d) {
          return MedicationInSession(
              id: d.id,
              medicineName: d.name,
              dosage: "${d.dosage} ${d.dosageUnit} - ${d.moment == 1 ? "Trước ăn" : "Sau ăn"}",
              isTaken: d.completedDate != null
          );
        }).toList();

        return PrescriptionInSessionModel(
          prescriptionId: presId,
          prescriptionName: presName,
          time: time,
          medications: medications,
          note: note,
        );
      }).toList();

      return PrescriptionsBySessionModel(
        id: session.name, // hoặc generate id riêng
        session: session,
        prescriptions: prescriptions,
      );
    }).toList();
  }
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
        return R.string.the_night.tr();
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
