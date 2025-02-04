import 'package:medical/src/widget/booking_clinic/model/clinic_speciality_model.dart';

class ClinicSpecialityListResponse {
  final int code;
  final SpecialityData data;
  final String success;
  final List<dynamic> attr;

  ClinicSpecialityListResponse({
    required this.code,
    required this.data,
    required this.success,
    required this.attr,
  });

  factory ClinicSpecialityListResponse.fromJson(Map<String, dynamic> json) {
    return ClinicSpecialityListResponse(
      code: json['code'],
      data: SpecialityData.fromJson(json['data']),
      success: json['success'],
      attr: json['attr'],
    );
  }
}

class SpecialityData {
  final List<Specialty> specialty;
  final List<Specialty> topSpecialty;

  SpecialityData({
    required this.specialty,
    required this.topSpecialty,
  });

  factory SpecialityData.fromJson(Map<String, dynamic> json) {
    return SpecialityData(
      specialty: (json['specialty'] as List)
          .map((item) => Specialty.fromJson(item))
          .toList(),
      topSpecialty: (json['top_specialty'] as List)
          .map((item) => Specialty.fromJson(item))
          .toList(),
    );
  }
}