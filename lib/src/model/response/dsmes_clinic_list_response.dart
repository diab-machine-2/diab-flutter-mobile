import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';

class DsmesClinicListResponse {
  final int code;
  final List<DsmesClinicModel> data;

  DsmesClinicListResponse({
    required this.code,
    required this.data,
  });

  factory DsmesClinicListResponse.fromJson(Map<String, dynamic> json) {
    return DsmesClinicListResponse(
      code: json['code'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => DsmesClinicModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
