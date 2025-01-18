class RescheduleDsmesBookingRequest {
  final AppointmentId appointmentId;
  final String startTime;

  RescheduleDsmesBookingRequest({
    required this.appointmentId,
    required this.startTime,
  });

  factory RescheduleDsmesBookingRequest.fromJson(Map<String, dynamic> json) {
    return RescheduleDsmesBookingRequest(
      appointmentId: AppointmentId.fromJson(json['appointment_id']),
      startTime: json['start_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId.toJson(),
      'start_time': startTime,
    };
  }
}

class AppointmentId {
  final int id;

  AppointmentId({required this.id});

  factory AppointmentId.fromJson(Map<String, dynamic> json) {
    return AppointmentId(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
