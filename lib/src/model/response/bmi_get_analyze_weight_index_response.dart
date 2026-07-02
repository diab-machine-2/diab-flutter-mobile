import 'package:medical/src/model/ai_recommendation_result.dart';
import 'package:medical/src/model/response/base/response.dart';

class BmiGetAnalyzeWeightIndexResponse {
    final Meta? meta;
    final AiRecommendationResult? data;

    BmiGetAnalyzeWeightIndexResponse({
        this.meta,
        this.data,
    });

    BmiGetAnalyzeWeightIndexResponse copyWith({
        Meta? meta,
        AiRecommendationResult? data,
    }) =>
        BmiGetAnalyzeWeightIndexResponse(
            meta: meta ?? this.meta,
            data: data ?? this.data,
        );

    factory BmiGetAnalyzeWeightIndexResponse.fromJson(Map<String, dynamic> json) {
      return BmiGetAnalyzeWeightIndexResponse(
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
