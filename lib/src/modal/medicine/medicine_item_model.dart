import 'dose_model.dart';
import 'image_note_model.dart';
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
  final int? amount;

  final String? customDay;
  final double? breakDay;

  final String? note;
  final List<ImageNoteModel>? imagesPatientMedications; //Dùng cho việc hiển thị sau khi lấy đơn thuốc và giữ lại hình khi update
  bool? isExistImage;
  Map<String, String>? uploadFiles; //Cho việc upload files

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
    this.imagesPatientMedications,
    this.uploadFiles,
  });

  factory MedicineItemModel.fromJson(Map<String, dynamic> json) {
    return MedicineItemModel(
      id: json['id'],
      medicationName: json['medicationName'],
      moment: json['moment'],
      frequency: json['frequency'],
      morning: (json['morning'] as num?)?.toDouble(),
      afternoon: (json['afternoon'] as num?)?.toDouble(),
      midDay: (json['midDay'] as num?)?.toDouble(),
      night: (json['night'] as num?)?.toDouble(),
      unit: json['unit'],
      amount: (json['amount'] as num?)?.toInt(),
      customDay: json['customDay'],
      breakDay: json['breakDay'],
      note: json['note'],
      imagesPatientMedications: ImageNoteModel.fromJsonList(json['imagesPatientMedications']),
    );
  }

  static List<MedicineItemModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => MedicineItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final json = {
      'medicationName': medicationName,
      'moment': moment,
      'frequency': frequency,
      'morning': morning,
      'afternoon': afternoon,
      'midDay': midDay,
      'night': night,
      'unit': unit,
      'amount': amount,
      'customDay': customDay,
      'breakDay': breakDay,
      'note': note,
    };
    // if (includeId && id != null) {
    //   json['id'] = id;
    // }
    return json;
  }

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
    int? amount,
    String? customDay,
    double? breakDay,
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

extension MedicineItemModelMapper on MedicineItemModel {
  static List<MedicineItemModel> fromJsonList(Map<String, dynamic> json) {
    final items = json['data']?['items'] as List<dynamic>?;

    if (items == null) return [];

    return items.map((e) {
      final map = e as Map<String, dynamic>;

      // Parse amount "63 viên" => 63
      final amount = int.tryParse(
        (map['amount'] as String?)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
      );

      // Parse frequency
      final freq = int.parse((map['frequency'] as String?) ?? '1');

      double morning = 0, afternoon = 0, midDay = 0, night = 0;

      switch (freq) {
        case 1:
          morning = 1;
          break;
        case 2:
          morning = 1;
          afternoon = 1;
          break;
        case 3:
          morning = 1;
          afternoon = 1;
          midDay = 1;
          break;
        case 4:
          morning = 1;
          afternoon = 1;
          midDay = 1;
          night = 1;
          break;
      }

      return MedicineItemModel(
        id: map['id'] as String?,
        medicationName: map['name'] as String?,
        note: map['instruction'] as String?,
        amount: amount,
        frequency: freq,
        moment: 1, // bạn có thể map thêm từ usageTime
        unit: 'viên',//parseUnit(map['amount']),
        morning: morning,
        afternoon: afternoon,
        midDay: midDay,
        night: night,
      );
    }).toList();
  }

  static String? parseUnit(String amount) {
    if (amount.isEmpty) return null;

    // Tách ra bằng regex: số + chữ
    final regex = RegExp(r'([\d.,]+)\s*(\D+)');
    final match = regex.firstMatch(amount.trim());

    if (match != null) {
      return match.group(2)?.trim(); // nhóm 2 là phần chữ (unit)
    }
    return null;
  }
}

