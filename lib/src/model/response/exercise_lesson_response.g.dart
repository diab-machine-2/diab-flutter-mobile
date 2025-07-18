// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_lesson_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseLessonResponse _$ExerciseLessonResponseFromJson(
        Map<String, dynamic> json) =>
    ExerciseLessonResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ExerciseLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ExerciseLessonResponseToJson(
        ExerciseLessonResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'statusCode': instance.statusCode,
      'message': instance.message,
    };

ExerciseLesson _$ExerciseLessonFromJson(Map<String, dynamic> json) =>
    ExerciseLesson(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExerciseLessonToJson(ExerciseLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'duration': instance.duration,
      'caloriesBurned': instance.caloriesBurned,
    };
