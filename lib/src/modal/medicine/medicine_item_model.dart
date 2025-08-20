import 'dose_model.dart';
import 'medicine_add_model.dart';

class MedicineItemModel {
  final String? id;
  final String? name;
  // final String? dosage;
  double quantity;
  // final int dose;
  List<DosageModel>? dosages;
  MedicineUnit? medicineUnit;
  // final String mealTime;
  // final String frequency;
  // final List<String> times;
  final String? note;

  MedicineItemModel({
    this.id,
    this.name,
    // required this.dosage,
    required this.quantity,
    // required this.dose,
    this.dosages,
    this.medicineUnit,
    // required this.mealTime,
    // required this.frequency,
    // required this.times,
    this.note,
  });

  factory MedicineItemModel.fromJson(Map<String, dynamic> json) {
    return MedicineItemModel(
      id: json['id'],
      name: json['name'],
      // dosage: json['dosage'],
      quantity: json['quantity'],
      // dose: json['usage'],
      dosages: json['dosages'] != null
          ? (json['dosages'] as List)
          .map((e) => DosageModel.fromJson(e))
          .toList()
          : null,

      // mealTime: json['mealTime'],
      // frequency: json['frequency'],
      // times: List<String>.from(json['times']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    // 'dosage': dosage,
    'quantity': quantity,
    // 'usage': dose,
    'dosages': dosages?.map((e) => e.toJson()).toList(),
    // 'mealTime': mealTime,
    // 'frequency': frequency,
    // 'times': times,
    'note': note,
  };
}

extension MedicineItemValidator on MedicineItemModel {
  bool get isValid {
    if (quantity <= 0) return false;
    if (dosages == null || dosages!.isEmpty) return false;
    return true;
  }
}