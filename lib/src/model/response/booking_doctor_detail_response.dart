import 'package:medical/src/widget/booking_doctor/model/booking_doctor_model.dart';

class BookingDoctorDetailResponse {
  final int code;
  final BookingDoctorModel data;

  BookingDoctorDetailResponse({
    required this.code,
    required this.data,
  });

  factory BookingDoctorDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookingDoctorDetailResponse(
      code: json['code'] ?? 0,
      data:  BookingDoctorModel.fromJson(json['data'] ?? {}),
    );
  }
}
