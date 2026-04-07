import 'dart:convert';

import 'package:medical/src/model/request/create_dsmes_booking_request.dart';

class DsmesAppointment {
  final int id;
  final String? prefix;
  final int? groupId;
  final int doctorId;
  final String requester;
  final int patientId;
  final String? patientAddress;
  final int clinicId;
  final String? diagnoses;
  final String symptom;
  final String startTime;
  final String endTime;
  final int appointmentTime;
  final String requestByProviders;
  final String? forChild;
  final String status;
  final String? memo;
  final String isShow;
  final int? repeatId;
  final String extraInfo;
  final int campaignId;
  final String? promotionCode;
  final String? affPartner;
  final String mode;
  final String type;
  final String chatWithDoctor;
  final String createdAt;
  final String updatedAt;
  final String? rescheduledAt;
  final int guestDoctor;
  final int doctorFeePayment;
  final dynamic mppFinance;
  final String contractType;
  final String? fromSource;
  final int showOnCalendar;
  final int? ratingId;
  final int showChat;
  final int showPayExtraService;
  final int showReschedule;
  final int showJoinCall;
  final int showCancel;
  final int showEditReview;
  final int showAddReview;
  final int showBookAgain;
  final int showChatWithDoctor;
  final int canReview;
  final int alreadyReview;
  final Doctor? doctor;
  final ClinicInfo clinic;
  final TeleMedicine? teleMedicine;
  final int hasAttachment;
  final int newAttachments;
  final int hasNewNote;
  final int hasNote;
  final PatientInfo patientInfo;
  final List<SymptomAttachment> symptomAttachment;
  final List<ServiceItem> services;
  final bool? isTest;
  final String? homeAddress;

  DsmesAppointment({
    required this.id,
    this.prefix,
    this.groupId,
    required this.doctorId,
    required this.requester,
    required this.patientId,
    this.patientAddress,
    required this.clinicId,
    this.diagnoses,
    required this.symptom,
    required this.startTime,
    required this.endTime,
    required this.appointmentTime,
    required this.requestByProviders,
    this.forChild,
    required this.status,
    this.memo,
    required this.isShow,
    this.repeatId,
    required this.extraInfo,
    required this.campaignId,
    this.promotionCode,
    this.affPartner,
    required this.mode,
    required this.type,
    required this.chatWithDoctor,
    required this.createdAt,
    required this.updatedAt,
    this.rescheduledAt,
    required this.guestDoctor,
    required this.doctorFeePayment,
    this.mppFinance,
    required this.contractType,
    this.fromSource,
    required this.showOnCalendar,
    this.ratingId,
    required this.showChat,
    required this.showPayExtraService,
    required this.showReschedule,
    required this.showJoinCall,
    required this.showCancel,
    required this.showEditReview,
    required this.showAddReview,
    required this.showBookAgain,
    required this.showChatWithDoctor,
    required this.canReview,
    required this.alreadyReview,
    required this.doctor,
    required this.clinic,
    required this.teleMedicine,
    required this.hasAttachment,
    required this.newAttachments,
    required this.hasNewNote,
    required this.hasNote,
    required this.patientInfo,
    required this.symptomAttachment,
    required this.services,
    this.isTest,
    this.homeAddress,
  });

  /// True when this appointment is examination-at-home (isTest and homeAddress set).
  /// Use this instead of repeating the condition; same meaning across list/detail.
  bool get isExaminationAtHome =>
      isTest == true &&
      homeAddress != null &&
      homeAddress!.isNotEmpty;

  factory DsmesAppointment.fromJson(Map<String, dynamic> json) {
    return DsmesAppointment(
      id: json['id'] ?? json['appointment_id'] ?? 0,
      prefix: json['prefix'],
      groupId: json['group_id'],
      doctorId: json['doctor_id'] ?? 0,
      requester: json['requester'] ?? '',
      patientId: json['patient_id'] ?? 0,
      patientAddress: json['patient_address'],
      clinicId: json['clinic_id'] ?? 0,
      diagnoses: json['diagnoses'],
      symptom: json['symptom'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      appointmentTime: json['appointment_time'] != null
          ? (json['appointment_time'] is String
              ? int.parse(json['appointment_time'])
              : json['appointment_time'])
          : 0,
      requestByProviders: json['request_by_providers'] ?? '',
      forChild: json['for_child'],
      status: json['status'] ?? '',
      memo: json['memo'],
      isShow: json['is_show'] ?? '',
      repeatId: json['repeat_id'],
      extraInfo: _extraInfoToString(json['extra_info'] ?? json['extraInfo']),
      campaignId: json['campaign_id'] ?? 0,
      promotionCode: json['promotion_code'],
      affPartner: json['aff_partner'],
      mode: json['mode'] ?? '',
      type: json['type'] ?? '',
      chatWithDoctor: json['chat_with_doctor'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      rescheduledAt: json['rescheduled_at'],
      guestDoctor: json['guest_doctor'] ?? 0,
      doctorFeePayment: json['doctor_fee_payment'] ?? 0,
      mppFinance: json['mpp_finance'],
      contractType: json['contract_type'] ?? '',
      fromSource: json['from_source'],
      showOnCalendar: json['show_on_calendar'] ?? 0,
      ratingId: json['rating_id'],
      showChat: json['show_chat'] ?? 0,
      showPayExtraService: json['show_pay_extra_service'] ?? 0,
      showReschedule: json['show_reschedule'] ?? 0,
      showJoinCall: json['show_join_call'] ?? 0,
      showCancel: json['show_cancel'] ?? 0,
      showEditReview: json['show_edit_review'] ?? 0,
      showAddReview: json['show_add_review'] ?? 0,
      showBookAgain: json['show_book_again'] ?? 0,
      showChatWithDoctor: json['show_chat_with_doctor'] ?? 0,
      canReview: json['can_review'] ?? 0,
      alreadyReview: json['already_review'] ?? 0,
      doctor: json['doctor_info'] is Map
          ? Doctor.fromJson(json['doctor_info'])
          : json['doctor'] is Map
              ? Doctor.fromJson(json['doctor'])
              : null,
      clinic: ClinicInfo.fromJson(json['clinic_info'] ?? json['clinic'] ?? {}),
      teleMedicine: json['teleMedicine'] != null && json['teleMedicine'] is Map
          ? TeleMedicine.fromJson(json['teleMedicine'])
          : null, // handle case empty response value is []
      hasAttachment: json['has_attachment'] ?? 0,
      newAttachments: json['new_attachments'] ?? 0,
      hasNewNote: json['has_new_note'] ?? 0,
      hasNote: json['has_note'] ?? 0,
      patientInfo: PatientInfo.fromJson(json['patient_info'] ?? {}),
      symptomAttachment: (json['symptom_attachment'] as List?)
              ?.map((e) => SymptomAttachment.fromJson(e))
              .toList() ??
          [],
      services: (json['paid_services']?['main_services']?['services'] as List?)
              ?.map((e) => ServiceItem.fromJson(e))
              .toList() ??
          [],
      isTest: _parseIsTestFromExtraInfo(json['extra_info'] ?? json['extraInfo'], json),
      homeAddress: _parseHomeAddressFromExtraInfo(json['extra_info'] ?? json['extraInfo'], json),
    );
  }

  /// extra_info shape differs by API:
  /// - List API (/api/patients/my-appointment-partner): extra_info is a JSON STRING.
  /// - Detail API (/api/patients/my-appointment-detail): extra_info is a Map (object).
  /// We always store extraInfo as String; isTest and homeAddress are parsed from either shape.

  /// Normalize extra_info to String for storage.
  static String _extraInfoToString(dynamic extraInfo) {
    if (extraInfo == null) return '';
    if (extraInfo is String) return extraInfo;
    if (extraInfo is Map) {
      try {
        return jsonEncode(extraInfo);
      } catch (_) {
        return '';
      }
    }
    return '';
  }

  /// Returns a Map for extra_info from either API shape.
  /// List API: extra_info is String -> jsonDecode(extraInfo).
  /// Detail API: extra_info is Map -> use as-is (copy to Map<String, dynamic>).
  static Map<String, dynamic>? _extraInfoAsMap(dynamic extraInfo) {
    if (extraInfo == null) return null;
    // Detail API: extra_info is already a Map
    if (extraInfo is Map) {
      return extraInfo is Map<String, dynamic>
          ? extraInfo
          : Map<String, dynamic>.from(extraInfo);
    }
    // List API: extra_info is a JSON string, must decode first
    if (extraInfo is String) {
      final s = extraInfo.trim();
      if (s.isEmpty) return null;
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        if (decoded is String) {
          final inner = jsonDecode(decoded);
          if (inner is Map) return Map<String, dynamic>.from(inner);
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static bool? _parseIsTestFromExtraInfo(dynamic extraInfo, Map<String, dynamic> json) {
    final map = _extraInfoAsMap(extraInfo);
    if (map != null) {
      final v = map['isTest'];
      if (v != null) {
        if (v is bool) return v;
        if (v is String) return v == 'true' || v == '1';
      }
    }
    return json['isTest'] as bool?;
  }

  static String? _parseHomeAddressFromExtraInfo(dynamic extraInfo, Map<String, dynamic> json) {
    final map = _extraInfoAsMap(extraInfo);
    if (map != null) {
      final v = map['homeAddress'];
      if (v != null) return v is String ? v : v.toString();
    }
    return json['homeAddress'] as String?;
  }
}

class ClinicInfo {
  final String name;
  final int id;
  final String lat;
  final String lng;
  final String address;
  final String avatar;

  ClinicInfo({
    required this.name,
    required this.id,
    required this.lat,
    required this.lng,
    required this.address,
    required this.avatar,
  });

  factory ClinicInfo.fromJson(Map<String, dynamic> json) {
    return ClinicInfo(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      address: json['address'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class PatientInfo {
  final int userId;
  final String? avatar;
  final String displayName;
  final String gender;
  final String birthday;
  final String phone;
  final String email;

  PatientInfo({
    required this.userId,
    this.avatar,
    required this.displayName,
    required this.gender,
    required this.birthday,
    required this.phone,
    required this.email,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      userId: json['user_id'] ?? 0,
      avatar: json['avatar'],
      displayName: json['display_name'] ?? '',
      gender: json['gender'] ?? '',
      birthday: json['birthday'] ?? '',
      phone: json['phone_number'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class SymptomAttachment {
  final String name;
  final String fileType;
  final String filePath;

  SymptomAttachment({
    required this.name,
    required this.fileType,
    required this.filePath,
  });

  factory SymptomAttachment.fromJson(Map<String, dynamic> json) {
    return SymptomAttachment(
      name: json['name'] ?? '',
      fileType: json['file_type'] ?? '',
      filePath: json['file_path'] ?? '',
    );
  }
}

class TeleMedicine {
  final int id;

  TeleMedicine({
    required this.id,
  });

  factory TeleMedicine.fromJson(Map<String, dynamic> json) {
    return TeleMedicine(
      id: json['id'] ?? 0,
    );
  }
}

class Doctor {
  final String displayName;
  final int graduate;
  final int id;
  final String avatar;
  final List<DoctorSpecialty> specialty;
  final String graduateName;
  final String name;

  Doctor({
    required this.displayName,
    required this.graduate,
    required this.id,
    required this.avatar,
    required this.specialty,
    required this.graduateName,
    required this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      displayName: json['display_name'] ?? '',
      graduate: json['graduate'] ?? 0,
      id: json['id'] ?? 0,
      avatar: json['avatar'] ?? '',
      specialty: (json['specialty'] as List?)
              ?.map((e) => DoctorSpecialty.fromJson(e))
              .toList() ??
          [],
      graduateName: json['graduate_name'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class DoctorSpecialty {
  final String name;
  final int specialtyId;
  final Pivot pivot;

  DoctorSpecialty({
    required this.name,
    required this.specialtyId,
    required this.pivot,
  });

  factory DoctorSpecialty.fromJson(Map<String, dynamic> json) {
    return DoctorSpecialty(
      name: json['name'] ?? '',
      specialtyId: json['specialty_id'] ?? 0,
      pivot: Pivot.fromJson(json['pivot'] ?? {}),
    );
  }
}

class Pivot {
  final int doctorId;
  final int specialtyId;

  Pivot({
    required this.doctorId,
    required this.specialtyId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      doctorId: json['doctor_id'] ?? 0,
      specialtyId: json['specialty_id'] ?? 0,
    );
  }
}

enum DsmesAppointmentMode {
  telemedicine,
  atClinic;

  static DsmesAppointmentMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'telemedicine':
        return DsmesAppointmentMode.telemedicine;
      case 'at_clinic':
        return DsmesAppointmentMode.atClinic;
      default:
        throw ArgumentError('Invalid DsmesAppointmentMode value: $value');
    }
  }

  String toString() {
    switch (this) {
      case DsmesAppointmentMode.telemedicine:
        return 'telemedicine';
      case DsmesAppointmentMode.atClinic:
        return 'at_clinic';
    }
  }
}

// DSMES Appointment Status
const String DSMES_STATUS_APPROVE = 'approve';
const String DSMES_STATUS_REJECT = 'reject';
const String DSMES_STATUS_REQUEST = 'request';
const String DSMES_STATUS_ON_HOLD = 'on-hold';
