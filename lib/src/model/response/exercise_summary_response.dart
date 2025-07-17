class ExerciseSummaryResponse {
  final Meta? meta;
  final ExerciseSummary? data;

  ExerciseSummaryResponse({
    this.meta,
    this.data,
  });

  factory ExerciseSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseSummaryResponse(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data:
          json['data'] != null ? ExerciseSummary.fromJson(json['data']) : null,
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

class ExerciseSummary {
  final String summaryId;
  final String summaryData;

  ExerciseSummary({
    required this.summaryId,
    required this.summaryData,
  });

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseSummary(
      summaryId: json['summaryId'],
      summaryData: json['summaryData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summaryId': summaryId,
      'summaryData': summaryData,
    };
  }
}
