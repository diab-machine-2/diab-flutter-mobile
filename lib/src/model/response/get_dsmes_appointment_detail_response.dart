import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';

class GetDsmesAppointmentDetailResponse {
  final int code;
  final DsmesAppointment data;

  GetDsmesAppointmentDetailResponse({
    required this.code,
    required this.data,
  });

  factory GetDsmesAppointmentDetailResponse.fromJson(
      Map<String, dynamic> json) {
    return GetDsmesAppointmentDetailResponse(
      code: json['code'] ?? 0,
      data: DsmesAppointment.fromJson(json['data'] ?? {}),
    );
  }
}
