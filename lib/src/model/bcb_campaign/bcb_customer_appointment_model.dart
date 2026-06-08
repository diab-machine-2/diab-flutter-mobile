class BcbCustomerAppointmentModel {
  final String? appointmentId;
  final String? campaignCustomerId;
  final String? slotId;
  final int? customerStatus;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? partnerId;
  final String? partnerName;
  final String? partnerAddress;
  final String? partnerHotline;
  final int? examDate; // unix timestamp
  final String? startTime;
  final String? endTime;
  final String? doctorNote;
  final String? medicalHistory;
  final int? submittedAt;

  BcbCustomerAppointmentModel({
    this.appointmentId,
    this.campaignCustomerId,
    this.slotId,
    this.customerStatus,
    this.fullName,
    this.phone,
    this.email,
    this.partnerId,
    this.partnerName,
    this.partnerAddress,
    this.partnerHotline,
    this.examDate,
    this.startTime,
    this.endTime,
    this.doctorNote,
    this.medicalHistory,
    this.submittedAt,
  });

  factory BcbCustomerAppointmentModel.fromJson(Map<String, dynamic> json) {
    return BcbCustomerAppointmentModel(
      appointmentId: json['appointmentId']?.toString(),
      campaignCustomerId: json['campaignCustomerId']?.toString(),
      slotId: json['slotId']?.toString(),
      customerStatus: json['customerStatus'] as int?,
      fullName: json['fullName']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      partnerId: json['partnerId']?.toString(),
      partnerName: json['partnerName']?.toString(),
      partnerAddress: json['partnerAddress']?.toString(),
      partnerHotline: json['partnerHotline']?.toString(),
      examDate: _parseUnix(json['examDate']),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      doctorNote: json['doctorNote']?.toString(),
      medicalHistory: json['medicalHistory']?.toString(),
      submittedAt: _parseUnix(json['submittedAt']),
    );
  }

  static int? _parseUnix(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Exam date in local timezone.
  DateTime? get examDateLocal {
    final u = examDate;
    if (u == null) return null;
    if (u > 20000000000) {
      return DateTime.fromMillisecondsSinceEpoch(u, isUtc: true).toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(u * 1000, isUtc: true).toLocal();
  }

  /// Formatted time range, e.g. "08:14-08:59"
  String get timeRange {
    String short(String? value) {
      final text = value ?? '';
      final parts = text.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return text;
    }
    return '${short(startTime)}-${short(endTime)}';
  }
}
