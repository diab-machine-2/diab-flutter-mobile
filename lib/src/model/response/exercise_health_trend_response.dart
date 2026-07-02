import 'package:medical/src/model/ai_recommendation_result.dart';

class ExerciseHealthTrendResponse {
  final AiRecommendationResult? data;
  final int? statusCode;
  final String? message;

  ExerciseHealthTrendResponse({
    this.data,
    this.statusCode,
    this.message,
  });

  factory ExerciseHealthTrendResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseHealthTrendResponse(
      data: AiRecommendationResult.fromDynamic(json['data']),
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (statusCode != null) {
      result['statusCode'] = statusCode;
    }
    if (message != null) {
      result['message'] = message;
    }
    if (data != null) {
      result['data'] = data!.toJson();
    }
    return result;
  }
}
