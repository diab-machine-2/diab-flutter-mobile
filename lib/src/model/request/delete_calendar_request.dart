class DeleteCalendarRequest {
  String id;
  String calendarCoachId;
  String deleteType;

  DeleteCalendarRequest({
    required this.id,
    required this.calendarCoachId,
    required this.deleteType,
  });

  factory DeleteCalendarRequest.fromJson(Map<String, dynamic> json) {
    return DeleteCalendarRequest(
      id: json['id'],
      calendarCoachId: json['calendarCoachId'],
      deleteType: json['deleteType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calendarCoachId': calendarCoachId,
      'deleteType': deleteType,
    };
  }
}
