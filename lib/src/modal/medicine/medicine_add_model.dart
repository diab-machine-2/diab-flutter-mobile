
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../res/R.dart';
import 'dose_model.dart';

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

  static MedicineUnit fromString(String? value) {
    if (value == null) return MedicineUnit.other;
    switch (value.toLowerCase()) {
      case "viên":
        return MedicineUnit.pill;
      case "gói":
        return MedicineUnit.package;
      case "ống":
        return MedicineUnit.tube;
      case "ml":
        return MedicineUnit.ml;
      default:
        return MedicineUnit.other;
    }
  }
}

enum DayTime {
  morning,
  noon,
  afternoon,
  night,
}

class Medication {
  String? id;
  String name;
  MedicineUnit medicineUnit;
  double quantity;
  List<DosageModel> dosages;
  String description;
  List<String> photos; // Stores file paths or URLs

  Medication({
    this.name = "",
    this.id,
    this.medicineUnit = MedicineUnit.pill,
    this.quantity = 0.0,
    this.dosages = const [],
    this.description = '',
    this.photos = const [],
  });
}

class DayTimeSchedule {
  final DayTime dayTime;
  final TimeOfDay time;

  DayTimeSchedule({
    required this.dayTime,
    required this.time,
  });
}