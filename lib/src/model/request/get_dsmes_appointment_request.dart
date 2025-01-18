class GetDsmesAppointmentRequest {
  int page;

  GetDsmesAppointmentRequest({
    required this.page,
  });

  factory GetDsmesAppointmentRequest.fromJson(Map<String, dynamic> json) {
    return GetDsmesAppointmentRequest(
      page: json['page'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
    };
  }
}
