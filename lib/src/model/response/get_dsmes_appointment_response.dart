import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';

class GetDsmesAppointmentResponse {
  final int code;
  final List<DsmesAppointment> data;
  final bool hasMore;
  final int currentPage;

  GetDsmesAppointmentResponse({
    required this.code,
    required this.data,
    required this.hasMore,
    required this.currentPage,
  });

  factory GetDsmesAppointmentResponse.fromJson(Map<String, dynamic> json) {
    final currentPage = json['attr']['pagination']['current_page'] ?? 1;
    final totalPage = json['attr']['pagination']['total_page'] ?? 1;
    return GetDsmesAppointmentResponse(
      code: json['code'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => DsmesAppointment.fromJson(e))
              .toList() ??
          [],
      currentPage: currentPage,
      hasMore: currentPage < totalPage,
    );
  }
}
