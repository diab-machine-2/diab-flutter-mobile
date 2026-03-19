import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

import 'daily_medicine_model.dart';

/// Moment label for dosage: 1 = Trước ăn, 2 = Sau ăn, 3 = Trong bữa ăn (aligned with medicine_card).
String _momentNameFromValue(int? moment) {
  if (moment == null) return '';
  switch (moment) {
    case 1:
      return R.string.truoc_an.tr();
    case 2:
      return R.string.sau_an.tr();
    case 3:
      return R.string.during_meal.tr();
    default:
      return R.string.truoc_an.tr();
  }
}

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

  static List<PrescriptionsBySessionModel> fromDailyList(
      List<DailyMedicineModel> dailyList) {
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
        final timeSchedule = presDailies.first.timeSchedule ?? '';

        // Convert list DailyMedicineModel -> MedicationInSession
        final medications = presDailies.map((d) {
          return MedicationInSession(
              id: d.id,
              patientMedicationId: d.patientMedicationId ?? '',
              medicineName: d.name,
              dosage:
                  "${d.dosage} ${d.dosageUnit} - ${_momentNameFromValue(d.moment)}",
              dosageValue: d.dosage,
              isTaken: d.completedDate != null);
        }).toList();

        return PrescriptionInSessionModel(
          prescriptionId: presId,
          prescriptionName: presName,
          timeSchedule: timeSchedule,
          medications: medications,
          note: note,
        );
      }).toList()
        // Sort prescriptions inside a session by timeSchedule (HH:mm:ss ascending)
        ..sort((a, b) {
          final ta = a.timeSchedule;
          final tb = b.timeSchedule;
          if (ta.isEmpty && tb.isEmpty) return 0;
          if (ta.isEmpty) return 1; // push empty/invalid to bottom
          if (tb.isEmpty) return -1;
          return ta.compareTo(tb);
        });

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

  /// Time of day as "HH:mm:ss" (e.g. "09:00:00"). Use with selected date to get full [DateTime].
  final String timeSchedule;
  final List<MedicationInSession> medications;
  final String? note;
  List<String>? photos;

  PrescriptionInSessionModel({
    required this.prescriptionId,
    required this.prescriptionName,
    required this.timeSchedule,
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
  /// Target id for URL (e.g. /App/Target/Medication/$id).
  final String id;

  /// From medicationInfo.patientMedicationId, for request body.
  final String patientMedicationId;
  final String medicineName;
  // e.g. 1 viên - Sau ăn
  final String dosage;

  /// Numeric dosage for API (e.g. Dosage in payload).
  final double dosageValue;
  // e.g. true ->
  bool isTaken;

  MedicationInSession({
    required this.id,
    required this.patientMedicationId,
    required this.medicineName,
    required this.dosage,
    required this.dosageValue,
    required this.isTaken,
  });
}
