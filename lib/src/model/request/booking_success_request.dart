class BookingSuccessRequest {
  String link;
  int appointmentDate;
  String coachName;

  BookingSuccessRequest({
    required this.link,
    required this.appointmentDate,
    required this.coachName,
  });

  factory BookingSuccessRequest.fromJson(Map<String, dynamic> json) {
    return BookingSuccessRequest(
      link: json['link'] ?? '',
      appointmentDate: json['appointmentDate'] ?? 0,
      coachName: json['coachName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'appointmentDate': appointmentDate,
      'coachName': coachName,
    };
  }
}
