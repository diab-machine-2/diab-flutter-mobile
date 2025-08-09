
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
  final DayTime timeOfDay;
  final String timing;
  final String frequency;
  final double quantity;

  Dosage({
    required this.timeOfDay,
    required this.timing,
    required this.frequency,
    required this.quantity,
  });

  String getIcon() {
    switch (timeOfDay) {
      case DayTime.morning:
        return R.icons.ic_morning;
      case DayTime.noon:
        return R.icons.ic_noon;
      case DayTime.afternoon:
        return R.icons.ic_afternoon;
      default:
        return R.icons.ic_night;
    }
  }

  String getDayTimeName() {
    switch (timeOfDay) {
      case DayTime.morning:
        return R.string.the_morning.tr();
      case DayTime.noon:
        return R.string.the_noon.tr();
      case DayTime.afternoon:
        return R.string.the_afternoon.tr();
      default:
        return R.string.the_evening.tr();
    }
  }
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