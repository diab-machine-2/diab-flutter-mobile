
import 'package:easy_localization/easy_localization.dart';

import '../../../res/R.dart';

enum MedicineUnit {
  pill,
  package,
  tube,
  ml,
  other;

  String getName() {
    switch (this) {
      case MedicineUnit.pill:
        return R.string.pill.tr();
      case MedicineUnit.package:
        return R.string.package.tr();
      case MedicineUnit.tube:
        return R.string.tube.tr();
      case MedicineUnit.ml:
        return "ml";
      default:
        return R.string.other.tr();
    }
  }
}

enum DayTime {
  morning,
  noon,
  afternoon,
  night,
}

class Dosage {
  // E.g. "Trước ăn", "Sau ăn", "Trong khi ăn"
  final String timeOfUse;
  // E.g. "Mỗi ngày", "Ngày trong tuần", "Cách ngày"
  final String frequency;

  // Use for "Mỗi ngày"
  final double quantityInMorning;
  final double quantityInNoon;
  final double quantityInAfternoon;
  final double quantityInNight;

  // Used for "Ngày trong tuần"
  final List<int> selectedDaysInWeek;
  final double quantityForDaysInWeek;

  // Used for "Cách ngày"
  final int everyOtherDayNumber;
  final double quantityForEveryOtherDay;

  Dosage({
    required this.timeOfUse,
    required this.frequency,

    this.quantityInMorning = 0.0,
    this.quantityInNoon = 0.0,
    this.quantityInAfternoon = 0.0,
    this.quantityInNight = 0.0,

    this.selectedDaysInWeek = const [],
    this.quantityForDaysInWeek = 0.0,

    this.everyOtherDayNumber = 0,
    this.quantityForEveryOtherDay = 0,
  });
}

class DraftPrescription {
  String? id;
  String name;
  MedicineUnit medicineUnit;
  double quantity;
  List<Dosage> dosages;
  String description;
  List<String> photos; // Stores file paths or URLs

  DraftPrescription({
    this.name = "",
    this.id,
    this.medicineUnit = MedicineUnit.pill,
    this.quantity = 0.0,
    this.dosages = const [],
    this.description = '',
    this.photos = const [],
  });
}