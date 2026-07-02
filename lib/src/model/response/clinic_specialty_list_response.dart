import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';

class ClinicSpecialtyListResponse {
  final int code;
  final List<ClinicSpecialty> data;
  final dynamic attr;

  ClinicSpecialtyListResponse({
    required this.code,
    required this.data,
    required this.attr,
  });

  factory ClinicSpecialtyListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return ClinicSpecialtyListResponse(
      code: json['code'] ?? 0,
      data: (rawData is List)
          ? rawData.map((item) => ClinicSpecialty.fromJson(item as Map<String, dynamic>)).toList()
          : [],
      attr: json['attr'],
    );
  }
}