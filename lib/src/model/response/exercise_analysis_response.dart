class ExerciseAnalysisResponse {
  final Meta? meta;
  final ExerciseAnalysis? data;

  ExerciseAnalysisResponse({
    this.meta,
    this.data,
  });

  factory ExerciseAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseAnalysisResponse(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data:
          json['data'] != null ? ExerciseAnalysis.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (meta != null) {
      result['meta'] = meta!.toJson();
    }
    if (data != null) {
      result['data'] = data!.toJson();
    }
    return result;
  }
}

class Meta {
  final bool? success;
  final String? message;

  Meta({
    this.success,
    this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (success != null) {
      result['success'] = success;
    }
    if (message != null) {
      result['message'] = message;
    }
    return result;
  }
}

class ExerciseAnalysis {
  final String exerciseId;
  final String analysisData;

  ExerciseAnalysis({
    required this.exerciseId,
    required this.analysisData,
  });

  factory ExerciseAnalysis.fromJson(Map<String, dynamic> json) {
    return ExerciseAnalysis(
      exerciseId: json['exerciseId'],
      analysisData: json['analysisData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'analysisData': analysisData,
    };
  }
}
