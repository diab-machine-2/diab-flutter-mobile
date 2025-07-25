import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ExerciseHealthTrendResponse {
  @JsonKey(name: "data")
  final String data;
  final int? statusCode;
  final String? message;

  ExerciseHealthTrendResponse({
    required this.data,
    this.statusCode,
    this.message,
  });

  factory ExerciseHealthTrendResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseHealthTrendResponse(
      data: json['data'] ?? '',
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
    if (data.isNotEmpty) {
      result['data'] = data;
    }
    return result;
  }
}
