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