import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';

class DsmesClinicDetailResponse {
  final int code;
  final DsmesClinicModel data;

  DsmesClinicDetailResponse({
    required this.code,
    required this.data,
  });

  factory DsmesClinicDetailResponse.fromJson(Map<String, dynamic> json) {
    return DsmesClinicDetailResponse(
      code: json['code'] ?? 0,
      data:  DsmesClinicModel.fromJson(json['data'] ?? {}),
    );
  }
}
