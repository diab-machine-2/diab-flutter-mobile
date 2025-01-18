import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';

class CreateDsmesOfflineBookingResponse {
  final int code;
  final DsmesAppointment data;

  CreateDsmesOfflineBookingResponse({
    required this.code,
    required this.data,
  });

  factory CreateDsmesOfflineBookingResponse.fromJson(
      Map<String, dynamic> json) {
    return CreateDsmesOfflineBookingResponse(
      code: json['code'] ?? 0,
      data: DsmesAppointment.fromJson(json['data'] ?? {}),
    );
  }
}
