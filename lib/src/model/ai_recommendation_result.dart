import 'package:medical/src/utils/api_error.dart';

class AiRecommendationResult {
  final String recommendation;
  final List<AiReference> references;

  /// Set when the analysis request failed, so the AI section can stop its
  /// loading indicator and say why ("Hệ thống đang gặp sự cố" /
  /// "Không có kết nối mạng") instead of spinning forever.
  final String? errorMessage;

  AiRecommendationResult({
    required this.recommendation,
    List<AiReference>? references,
    this.errorMessage,
  }) : references = references ?? [];

  /// A failed analysis. [error] is whatever the request threw (or null when
  /// the backend answered without usable data).
  factory AiRecommendationResult.failure(Object? error) =>
      AiRecommendationResult(
        recommendation: '',
        errorMessage: apiErrorMessage(error),
      );

  factory AiRecommendationResult.fromJson(Map<String, dynamic> json) {
    return AiRecommendationResult(
      recommendation: json['recommendation'] as String? ?? '',
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => AiReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory AiRecommendationResult.fromDynamic(dynamic data) {
    if (data is Map<String, dynamic>) {
      return AiRecommendationResult.fromJson(data);
    }
    if (data is String) {
      return AiRecommendationResult(recommendation: data);
    }
    return AiRecommendationResult(recommendation: '');
  }

  Map<String, dynamic>? toJson() {
    return {
      'recommendation': recommendation,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }

  bool get isEmpty => recommendation.isEmpty;
}

class AiReference {
  final String title;
  final String url;

  AiReference({required this.title, required this.url});

  factory AiReference.fromJson(Map<String, dynamic> json) {
    return AiReference(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
    };
  }
}

