class AiRecommendationResult {
  final String recommendation;
  final List<AiReference> references;

  AiRecommendationResult({
    required this.recommendation,
    List<AiReference>? references,
  }) : references = references ?? [];

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

