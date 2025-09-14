import 'medicine_item_model.dart';
import 'reminder_model.dart';
import 'package:medical/src/widget/helper/helper.dart';

class PrescriptionModel {
  final String? id;
  String? prescriptionName;
  final DateTime? startDate;
  final String? note;
  final List<MedicineItemModel>? patientMedications;
  final List<ReminderModel>? reminderTimes;
  final int? remainDays;
  final bool? isNotify;
  String? description;
  List<String>? photos;
  final int? status; //0: Đang dùng, 1: Ngưng dùng

  PrescriptionModel({
    this.id,
    this.prescriptionName,
    this.startDate,
    this.note,
    this.patientMedications,
    this.reminderTimes,
    this.remainDays,
    this.isNotify,
    this.description,
    this.photos,
    this.status
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String?,
      prescriptionName: json['prescriptionName'] as String?,
      startDate: toDate(json['startDate']),
      note: json['note'] as String?,
      patientMedications: (json['patientMedications'] as List?)
          ?.map((e) => MedicineItemModel.fromJson(e))
          .toList(),
      reminderTimes: (json['reminderTimes'] as List?)
          ?.map((e) => ReminderModel.fromJson(e))
          .toList(),
      remainDays: json['remainDays'] as int?,
      isNotify: json['isNotify'] as bool?,
      description: json['description'] as String?,
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList(),
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'prescriptionName': prescriptionName,
    'startDate': startDate != null
        ? (startDate!.millisecondsSinceEpoch ~/ 1000)
        : null,
    'note': note,
    'patientMedications': patientMedications?.map((e) => e.toJson()).toList(),
    'reminderTimes': reminderTimes?.map((e) => e.toJson()).toList(),
    'remainDays': remainDays,
    'isNotify': isNotify,
    'description': description,
    'photos': photos,
    'status': status,
  };

  PrescriptionModel copyWith({
    String? id,
    String? prescriptionName,
    DateTime? startDate,
    String? note,
    List<MedicineItemModel>? patientMedications,
    List<ReminderModel>? reminderTimes,
    int? remainDays,
    bool? isNotify,
    String? description,
    List<String>? photos,
    int? status,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      prescriptionName: prescriptionName ?? this.prescriptionName,
      startDate: startDate ?? this.startDate,
      note: note ?? this.note,
      patientMedications: patientMedications ?? this.patientMedications,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      remainDays: remainDays ?? this.remainDays,
      isNotify: isNotify ?? this.isNotify,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      status: status ?? this.status,
    );
  }

  static List<PrescriptionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => PrescriptionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

extension PrescriptionValidator on PrescriptionModel {
  bool get isValid {
    //if (name == null || name?.isEmpty == true) return false;
    if (patientMedications == null) return false;
    if (patientMedications?.isEmpty == true) return false;
    for (final med in patientMedications!) {
      if (!med.isValid) return false;
    }
    return true;
  }
}
