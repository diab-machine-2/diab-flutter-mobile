class ReminderModel {
  final String label; // "Buổi sáng", "Buổi tối"
  final String time; // "09:00", "20:30"

  ReminderModel({required this.label, required this.time});

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      label: json['label'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'time': time,
  };
}