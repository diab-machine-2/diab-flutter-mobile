class CreateDsmesBookingRequest {
  final String startTime;
  final String endTime;
  final int clinicId;
  final int doctorId;
  final String patientPhoneNumber;
  final String patientName;
  final String birthday;
  final int patientGender;
  final String patientEmail;
  final String extraInfo;
  final int bookingForClinic;
  final String language;
  final String symptom;
  final List<String> symptomAttachment;

  CreateDsmesBookingRequest({
    required this.startTime,
    required this.endTime,
    required this.clinicId,
    required this.doctorId,
    required this.patientPhoneNumber,
    required this.patientName,
    required this.birthday,
    required this.patientGender,
    required this.patientEmail,
    this.extraInfo = '',
    required this.bookingForClinic,
    required this.language,
    required this.symptom,
    required this.symptomAttachment,
  });

  factory CreateDsmesBookingRequest.fromJson(Map<String, dynamic> json) {
    return CreateDsmesBookingRequest(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      clinicId: json['clinic_id'] as int,
      doctorId: json['doctor_id'] as int,
      patientPhoneNumber: json['patient_phone_number'] as String,
      patientName: json['patient_name'] as String,
      birthday: json['birthday'] as String,
      patientGender: json['patient_gender'] as int,
      patientEmail: json['patient_email'] as String,
      extraInfo: json['extra_info'] as String? ?? '',
      bookingForClinic: json['booking_for_clinic'] as int,
      language: json['language'] as String,
      symptom: json['symptom'] as String,
      symptomAttachment: (json['symptom_attachment'] as List<String>?) ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'patient_phone_number': patientPhoneNumber,
      'patient_name': patientName,
      'birthday': birthday,
      'patient_gender': patientGender,
      'patient_email': patientEmail,
      'extra_info': extraInfo,
      'booking_for_clinic': bookingForClinic,
      'language': language,
      'symptom': symptom,
      'symptom_attachment': symptomAttachment,
    };
  }

  CreateDsmesBookingRequest copyWith({
    String? startTime,
    String? endTime,
    int? clinicId,
    int? doctorId,
    String? patientPhoneNumber,
    String? patientName,
    String? birthday,
    int? patientGender,
    String? patientEmail,
    String? extraInfo,
    int? bookingForClinic,
    String? language,
    String? symptom,
    List<String>? symptomAttachment,
  }) {
    return CreateDsmesBookingRequest(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      clinicId: clinicId ?? this.clinicId,
      doctorId: doctorId ?? this.doctorId,
      patientPhoneNumber: patientPhoneNumber ?? this.patientPhoneNumber,
      patientName: patientName ?? this.patientName,
      birthday: birthday ?? this.birthday,
      patientGender: patientGender ?? this.patientGender,
      patientEmail: patientEmail ?? this.patientEmail,
      extraInfo: extraInfo ?? this.extraInfo,
      bookingForClinic: bookingForClinic ?? this.bookingForClinic,
      language: language ?? this.language,
      symptom: symptom ?? this.symptom,
      symptomAttachment: symptomAttachment ?? this.symptomAttachment,
    );
  }
}
