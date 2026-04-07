class ReminderModel {
  final String timeSchedule; // "09:00", "20:30"
  final int type; // 1->4: sáng, trưa, chiều, tối

  ReminderModel({required this.timeSchedule, required this.type});

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      timeSchedule: json['timeSchedule'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'timeSchedule': timeSchedule,
    'type': type,
  };
}