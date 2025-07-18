import 'package:json_annotation/json_annotation.dart';

part 'exercise_lesson_response.g.dart';

@JsonSerializable()
class ExerciseLessonResponse {
  @JsonKey(name: "data")
  final List<ExerciseLesson>? data;
  final int? statusCode;
  final String? message;

  ExerciseLessonResponse({this.data, this.statusCode, this.message});

  factory ExerciseLessonResponse.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLessonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseLessonResponseToJson(this);
}

@JsonSerializable()
class ExerciseLesson {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "description")
  final String? description;

  @JsonKey(name: "videoUrl")
  final String? videoUrl;

  @JsonKey(name: "thumbnailUrl")
  final String? thumbnailUrl;

  @JsonKey(name: "duration")
  final double? duration;

  @JsonKey(name: "caloriesBurned")
  final double? caloriesBurned;

  ExerciseLesson({
    this.id,
    this.name,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.caloriesBurned,
  });

  factory ExerciseLesson.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLessonFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseLessonToJson(this);
}
