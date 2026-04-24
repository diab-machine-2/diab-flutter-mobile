import 'bcb_exam_result_model.dart';

class BcbAppointmentWishModel {
  String? slotId;
  int? priority; // 1, 2, 3
  DateTime? slotStartTime;
  DateTime? slotEndTime;
  DateTime? examDate;

  BcbAppointmentWishModel({
    this.slotId,
    this.priority,
    this.slotStartTime,
    this.slotEndTime,
    this.examDate,
  });

  factory BcbAppointmentWishModel.fromJson(Map<String, dynamic> json) {
    return BcbAppointmentWishModel(
      slotId: json['slotId'] as String?,
      priority: json['priority'] as int?,
      slotStartTime: json['slotStartTime'] != null
          ? DateTime.tryParse(json['slotStartTime'].toString())
          : null,
      slotEndTime: json['slotEndTime'] != null
          ? DateTime.tryParse(json['slotEndTime'].toString())
          : null,
      examDate: json['examDate'] != null
          ? DateTime.tryParse(json['examDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'priority': priority,
      'slotStartTime': slotStartTime?.toIso8601String(),
      'slotEndTime': slotEndTime?.toIso8601String(),
      'examDate': examDate?.toIso8601String(),
    };
  }
}

class BcbCustomerRegistrationModel {
  String? id;
  String? campaignCustomerId;
  String? doctorNote;
  String? medicalHistory;
  List<BcbAppointmentWishModel>? wishes; // 3 slot ưu tiên

  BcbCustomerRegistrationModel({
    this.id,
    this.campaignCustomerId,
    this.doctorNote,
    this.medicalHistory,
    this.wishes,
  });

  factory BcbCustomerRegistrationModel.fromJson(Map<String, dynamic> json) {
    return BcbCustomerRegistrationModel(
      id: json['id'] as String?,
      campaignCustomerId: json['campaignCustomerId'] as String?,
      doctorNote: json['doctorNote'] as String?,
      medicalHistory: json['medicalHistory'] as String?,
      wishes: json['wishes'] != null
          ? (json['wishes'] as List<dynamic>)
              .map((e) => BcbAppointmentWishModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignCustomerId': campaignCustomerId,
      'doctorNote': doctorNote,
      'medicalHistory': medicalHistory,
      'wishes': wishes?.map((e) => e.toJson()).toList(),
    };
  }
}

class BcbCustomerAppointmentModel {
  String? id;
  String? campaignCustomerId;
  DateTime? appointmentDate;
  String? clinicName;
  String? doctorName;
  int? status;

  BcbCustomerAppointmentModel({
    this.id,
    this.campaignCustomerId,
    this.appointmentDate,
    this.clinicName,
    this.doctorName,
    this.status,
  });

  factory BcbCustomerAppointmentModel.fromJson(Map<String, dynamic> json) {
    return BcbCustomerAppointmentModel(
      id: json['id'] as String?,
      campaignCustomerId: json['campaignCustomerId'] as String?,
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'].toString())
          : null,
      clinicName: json['clinicName'] as String?,
      doctorName: json['doctorName'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignCustomerId': campaignCustomerId,
      'appointmentDate': appointmentDate?.toIso8601String(),
      'clinicName': clinicName,
      'doctorName': doctorName,
      'status': status,
    };
  }
}

class BcbCustomerModel {
  String? id;
  String? campaignId;
  String? fullName;
  String? phone;
  int? status; // 1..10 state machine
  BcbCustomerRegistrationModel? registration;
  BcbCustomerAppointmentModel? appointment;
  BcbExamResultModel? examResult;

  BcbCustomerModel({
    this.id,
    this.campaignId,
    this.fullName,
    this.phone,
    this.status,
    this.registration,
    this.appointment,
    this.examResult,
  });

  factory BcbCustomerModel.fromJson(Map<String, dynamic> json) {
    return BcbCustomerModel(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as int?,
      registration: json['registration'] != null
          ? BcbCustomerRegistrationModel.fromJson(
              json['registration'] as Map<String, dynamic>)
          : null,
      appointment: json['appointment'] != null
          ? BcbCustomerAppointmentModel.fromJson(
              json['appointment'] as Map<String, dynamic>)
          : null,
      examResult: json['examResult'] != null
          ? BcbExamResultModel.fromJson(json['examResult'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'fullName': fullName,
      'phone': phone,
      'status': status,
      'registration': registration?.toJson(),
      'appointment': appointment?.toJson(),
      'examResult': examResult?.toJson(),
    };
  }
}
