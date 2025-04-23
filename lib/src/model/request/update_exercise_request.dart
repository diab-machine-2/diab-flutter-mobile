class UpdateExerciseRequest {
  final String exerciseId;
  final String seq; // Đổi kiểu dữ liệu từ int thành String
  final String description;
  final double duration;
  final double burnedCalorie;
  final String intensityId;

  UpdateExerciseRequest({
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
}
