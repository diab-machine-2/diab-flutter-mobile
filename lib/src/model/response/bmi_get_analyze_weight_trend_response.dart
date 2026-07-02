import 'package:medical/src/model/ai_recommendation_result.dart';
import 'package:medical/src/model/response/base/response.dart';

class BmiGetAnalyzeWeightTrendResponse {
    final Meta? meta;
    final AiRecommendationResult? data;

    BmiGetAnalyzeWeightTrendResponse({
        this.meta,
        this.data,
    });

    BmiGetAnalyzeWeightTrendResponse copyWith({
        Meta? meta,
        AiRecommendationResult? data,
    }) =>
        BmiGetAnalyzeWeightTrendResponse(
            meta: meta ?? this.meta,
            data: data ?? this.data,
        );

    factory BmiGetAnalyzeWeightTrendResponse.fromJson(Map<String, dynamic> json) {
      return BmiGetAnalyzeWeightTrendResponse(
        meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
        data: AiRecommendationResult.fromDynamic(json['data']),
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'meta': meta?.toJson(),
        'data': data?.toJson(),
      };
    }
}
