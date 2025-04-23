class AddExerciseRequest {
  final String date;
  final String note; // Thêm trường note
  final List<ExerciseDetail> exercises;

  AddExerciseRequest({
    required this.date,
    required this.note, // Thêm note vào constructor
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'note': note, // Thêm note vào JSON
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class ExerciseDetail {
  final String exerciseId;
  final String seq; // Đổi kiểu dữ liệu từ int thành String
  final String description;
  final double duration;
  final double burnedCalorie;
  final String intensityId;

  ExerciseDetail({
    required this.exerciseId,
    required this.seq, // Cập nhật constructor
    required this.description,
    required this.duration,
    required this.burnedCalorie,
    required this.intensityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'seq': seq, // Cập nhật JSON
      'description': description,
      'duration': duration,
      'burnedCalorie': burnedCalorie,
      'intensityId': intensityId,
    };
  }

  static List<ExerciseDetail> toList(List<dynamic> items) {
    return items.map((item) => ExerciseDetail.fromJson(item)).toList();
  }

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    return ExerciseDetail(
      exerciseId: json['exerciseId'] as String,
      seq: json['seq'] as String,
      description: json['description'] as String,
      duration: (json['duration'] as num).toDouble(),
      burnedCalorie: (json['burnedCalorie'] as num).toDouble(),
      intensityId: json['intensityId'] as String,
    );
  }
}
