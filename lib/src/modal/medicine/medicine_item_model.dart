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
      if (includeId && id != null) 'id': id,
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

    json.removeWhere((key, value) => value == null);

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

      final amount = int.tryParse(map['amount']?.toString() ?? '');

      return MedicineItemModel(
        medicationName: map['name'] as String?,

        moment: parseMoment(map['usageTime'] as String?),
        frequency: 1, // mỗi ngày (BE hiện chưa trả → fix cứng)

        morning: double.tryParse(map['morning']?.toString() ?? '0'),
        afternoon: double.tryParse(map['afternoon']?.toString() ?? '0'),
        midDay: double.tryParse(map['midDay']?.toString() ?? '0'), // nếu BE chưa có → null / 0
        night: double.tryParse(map['night']?.toString() ?? '0'),

        unit: map['unit'] as String?,
        amount: amount,

        note: map['instruction'] as String?,
      );
    }).toList();
  }

  static int? parseMoment(String? usageTime) {
    if (usageTime == null) return null;

    switch (usageTime.toLowerCase()) {
      case 'trước ăn':
        return 1;
      case 'sau ăn':
        return 2;
      case 'trong khi ăn':
        return 3;
      default:
        return null;
    }
  }
}

