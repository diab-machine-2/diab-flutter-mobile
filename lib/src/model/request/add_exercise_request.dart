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
  final String? exerciseCategoryId;
  final String? code;
  final String? name;
  final String? intensityName;
  final double? defaultMets;
  final double? mets;

  ExerciseDetail({
    required this.exerciseId,
    required this.seq, // Cập nhật constructor
    required this.description,
    required this.duration,
    required this.burnedCalorie,
    required this.intensityId,
    this.exerciseCategoryId,
    this.code,
    this.name,
    this.intensityName,
    this.defaultMets,
    this.mets,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'seq': seq, // Cập nhật JSON
      'description': description,
      'duration': duration,
      'burnedCalorie': burnedCalorie,
      'intensityId': intensityId,
      'exerciseCategoryId': exerciseCategoryId,
      'code': code,
      'name': name,
      'intensityName': intensityName,
      'defaultMets': defaultMets,
      'mets': mets,
    };
  }

  static List<ExerciseDetail> toList(List<dynamic> items) {
    return items.map((item) => ExerciseDetail.fromJson(item)).toList();
  }

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    return ExerciseDetail(
      exerciseId: json['exerciseId'] != null ? json['exerciseId'] : json['id'],
      seq: json['seq']?.toString() ?? '', // Chuyển đổi seq thành String
      description: json['description'] ?? '',
      duration: json['duration']?.toDouble() ?? 0.0,
      burnedCalorie: json['burnedCalorie']?.toDouble() ?? 0.0,
      intensityId: json['intensityId'] ?? '',
      exerciseCategoryId: json['exerciseCategoryId']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      intensityName: json['intensityName']?.toString() ?? '',
      defaultMets: json['defaultMets']?.toDouble() ?? 0.0,
      mets: json['mets']?.toDouble() ?? 0.0,
    );
  }
}
