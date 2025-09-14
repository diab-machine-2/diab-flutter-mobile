import 'dose_model.dart';
import 'medicine_add_model.dart';

class MedicineItemModel {
  final String? id;
  final String? medicationName;

  final int? moment; //1: Trước ăn, 2: Sau ăn, 3: Trong khi ăn
  final int? frequency; //1: Mỗi ngày, 2: Ngày trong tuần, 3: Cách ngày

  /// liều theo buổi
  final double? morning;
  final double? afternoon;
  final double? midDay;
  final double? night;

  final String? unit; // viên, gói, ống, ml, khác
  final double? amount;

  final String? customDay;
  final int? breakDay;

  final String? note;

  MedicineItemModel({
    this.id,
    this.medicationName,
    this.moment,
    this.frequency,
    this.morning,
    this.afternoon,
    this.midDay,
    this.night,
    this.unit,
    this.amount,
    this.customDay,
    this.breakDay,
    this.note,
  });

  factory MedicineItemModel.fromJson(Map<String, dynamic> json) {
    return MedicineItemModel(
      id: json['id'],
      medicationName: json['medicationName'],
      moment: json['moment'],
      frequency: json['frequency'],
      morning: json['morning'],
      afternoon: json['afternoon'],
      midDay: json['midDay'],
      night: json['night'],
      unit: json['unit'],
      amount: (json['amount'] as num?)?.toDouble(),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationName': medicationName,
    'frequency': frequency,
    'morning': morning,
    'afternoon': afternoon,
    'midDay': midDay,
    'night': night,
    'unit': unit,
    'amount': amount,
    'note': note,
  };

  MedicineItemModel copyWith({
    String? id,
    String? name,
    int? moment,
    int? frequency,
    double? morning,
    double? afternoon,
    double? midDay,
    double? night,
    String? unit,
    double? amount,
    String? customDay,
    int? breakDay,
    String? note,
  }) {
    return MedicineItemModel(
      id: id ?? this.id,
      medicationName: name ?? this.medicationName,
      moment: moment ?? this.moment,
      frequency: frequency ?? this.frequency,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      midDay: midDay ?? this.midDay,
      night: night ?? this.night,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      customDay: customDay ?? this.customDay,
      breakDay: breakDay ?? this.breakDay,
      note: note ?? this.note,
    );
  }
}

extension MedicineItemValidator on MedicineItemModel {
  bool get isValid {
    if ((amount ?? 0) <= 0) return false;
    // if (dosages == null || dosages!.isEmpty) return false;
    return true;
  }
}