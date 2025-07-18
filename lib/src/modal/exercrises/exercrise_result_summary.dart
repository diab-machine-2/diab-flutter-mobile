import 'dart:convert';

class ExerciseResultSummary {
  final int completedMinutes;
  final int targetMinutes;
  final int completedCalories;
  final int targetCalories;

  ExerciseResultSummary({
    required this.completedMinutes,
    required this.targetMinutes,
    required this.completedCalories,
    required this.targetCalories,
  });

  double get minutesCompletionPercentage =>
      targetMinutes > 0 ? (completedMinutes / targetMinutes) * 100 : 0;

  double get caloriesCompletionPercentage =>
      targetCalories > 0 ? (completedCalories / targetCalories) * 100 : 0;

  factory ExerciseResultSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseResultSummary(
      completedMinutes: json['completed_minutes'] ?? 0,
      targetMinutes: json['target_minutes'] ?? 45, // Default target
      completedCalories: json['completed_calories'] ?? 0,
      targetCalories: json['target_calories'] ?? 800, // Default target
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_minutes': completedMinutes,
      'target_minutes': targetMinutes,
      'completed_calories': completedCalories,
      'target_calories': targetCalories,
    };
  }
}

class ExerciseActivity {
  final String id;
  final String name;
  final String time;
  final int durationMinutes;
  final int calories;
  final String imageUrl;

  ExerciseActivity({
    required this.id,
    required this.name,
    required this.time,
    required this.durationMinutes,
    required this.calories,
    required this.imageUrl,
  });

  factory ExerciseActivity.fromJson(Map<String, dynamic> json) {
    return ExerciseActivity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      calories: json['calories'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'duration_minutes': durationMinutes,
      'calories': calories,
      'image_url': imageUrl,
    };
  }
}
