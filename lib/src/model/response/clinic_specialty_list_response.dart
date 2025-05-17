import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';

class ClinicSpecialtyListResponse {
  final int code;
  final List<ClinicSpecialty> data;
  final List<dynamic> attr;

  ClinicSpecialtyListResponse({
    required this.code,
    required this.data,
    required this.attr,
  });

  factory ClinicSpecialtyListResponse.fromJson(Map<String, dynamic> json) {
    return ClinicSpecialtyListResponse(
      code: json['code'],
      data: (json['data'] as List)
          .map((item) => ClinicSpecialty.fromJson(item))
          .toList(),
      attr: json['attr'],
    );
  }
}