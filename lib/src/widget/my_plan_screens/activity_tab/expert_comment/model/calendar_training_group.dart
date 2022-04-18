class CalendarTrainingGroup {
  CalendarTrainingGroup({
    required this.calendarId,
    required this.trainingGroupId,
    required this.comment,
    required this.coachId,
    required this.id,
    required this.type,
    required this.coachDate,
    required this.coachName,
  });

  final String? calendarId;
  final String? trainingGroupId;
  final String? comment;
  final String? coachId;
  final String? id;
  final int? type;
  final String? coachDate;
  final String? coachName;

//  DateTime? get time => DateUtil.parseStringToDate(updateDateTime, 'dd/MM/yyyy');

   @override
  factory CalendarTrainingGroup.fromJson(Map<String, dynamic> json) {
    return CalendarTrainingGroup(
      trainingGroupId: json['trainingGroupId'],
      calendarId: json['calendarId'],
      comment: json['comment'],
      coachId: json['coachId'],
      id: json['id'],
      type: json['type'],
      coachDate: json['coachDate'],
      coachName: json['coachName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["trainingGroupId"] = trainingGroupId;
    data["calendarId"] = calendarId;
    data["comment"] = comment;
    data["coachId"] = coachId;
    data['id'] = id;
    data["type"] = type;
    data["coachDate"] = coachDate;
    data["coachName"] = coachName;
    return data;
  }

  static List<CalendarTrainingGroup> toList(List<dynamic> items) {
    return items.map((item) => CalendarTrainingGroup.fromJson(item)).toList();
  }
}