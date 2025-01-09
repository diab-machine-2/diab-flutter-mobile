class DsmesCancelBookingRequest {
  int id;
  List<String> reason;

  DsmesCancelBookingRequest({
    required this.id,
    required this.reason,
  });

  factory DsmesCancelBookingRequest.fromJson(Map<String, dynamic> json) {
    return DsmesCancelBookingRequest(
      id: json['id'] ?? 0,
      reason: json['reason'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
    };
  }
}
