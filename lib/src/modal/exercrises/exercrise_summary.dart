import 'package:meta/meta.dart';
@immutable
class ExercriseSummaryModel {
  final double? targetDuration;
  final double? factDuration;
  final double? durationRatio;
  final double? burnedCalories;
  final ImagesUrlModel? mainExerciseIconUrl;
  final String? mainExerciseName;
  final double? mainExerciseDuration;
  final ImagesUrlModel? otherExerciseIconUrl;
  final String? otherExerciseName;
  final double? otherExerciseDuration;

  const ExercriseSummaryModel({
    required this.targetDuration,
    required this.factDuration,
    required this.durationRatio,
    required this.burnedCalories,
    required this.mainExerciseIconUrl,
    required this.mainExerciseName,
    required this.mainExerciseDuration,
    required this.otherExerciseIconUrl,
    required this.otherExerciseName,
    required this.otherExerciseDuration,
  });
  @override
  factory ExercriseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExercriseSummaryModel(
        targetDuration: json['targetDuration'],
        factDuration: json['factDuration'],
        durationRatio: json['durationRatio'],
        burnedCalories: json['burnedCalories'],
        mainExerciseIconUrl: json['mainExerciseIconUrl'] == null
            ? null
            : ImagesUrlModel.fromJson(json['mainExerciseIconUrl']),
        mainExerciseName: json['mainExerciseName'],
        mainExerciseDuration: json['mainExerciseDuration'],
        otherExerciseIconUrl: json['otherExerciseIconUrl'] == null
            ? null
            : ImagesUrlModel.fromJson(json['otherExerciseIconUrl']),
        otherExerciseName: json['otherExerciseName'],
        otherExerciseDuration: json['otherExerciseDuration']);
  }

  static List<ExercriseSummaryModel> toList(List<dynamic> items) {
    return items.map((item) => ExercriseSummaryModel.fromJson(item)).toList();
  }
}

class ImagesUrlModel {
  final String? id;
  final String? url;

  ImagesUrlModel({required this.id, required this.url});
  @override
  factory ImagesUrlModel.fromJson(Map<String, dynamic> json) {
    return ImagesUrlModel(
      id: json['id'],
      url: json['url'],
    );
  }
}
