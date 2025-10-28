import 'package:json_annotation/json_annotation.dart';
import 'package:medical/src/model/response/base/response.dart';

part 'bmi_weight_statistical_response.g.dart';


@JsonSerializable()
class BmiWeightStatisticalResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final BmiWeightStatistical? data;

    BmiWeightStatisticalResponse({
        this.meta,
        this.data,
    });

    factory BmiWeightStatisticalResponse.fromJson(Map<String, dynamic> json) => _$BmiWeightStatisticalResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiWeightStatisticalResponseToJson(this);
}

@JsonSerializable()
class BmiWeightStatistical {
    @JsonKey(name: "safeWeightFrom")
    final double? safeWeightFrom;
    @JsonKey(name: "safeWeightTo")
    final double? safeWeightTo;
    @JsonKey(name: "weightSafes")
    final List<WeightSafe>? weightSafes;
    @JsonKey(name: "current")
    final double? current;
    @JsonKey(name: "lowest")
    final double? lowest;
    @JsonKey(name: "highest")
    final double? highest;
    @JsonKey(name: "goal")
    final double? goal;
    @JsonKey(name: "message")
    final String? message;
    @JsonKey(name: "iconUrl")
    final String? iconUrl;
    @JsonKey(name: "trendItems")
    final List<WeightStatisticRecord>? trendItems;

    BmiWeightStatistical({
        this.safeWeightFrom,
        this.safeWeightTo,
        this.weightSafes,
        this.current,
        this.lowest,
        this.highest,
        this.goal,
        this.message,
        this.iconUrl,
        this.trendItems,
    });

    factory BmiWeightStatistical.fromJson(Map<String, dynamic> json) => _$BmiWeightStatisticalFromJson(json);

    Map<String, dynamic> toJson() => _$BmiWeightStatisticalToJson(this);
}

@JsonSerializable()
class WeightStatisticRecord {
    @JsonKey(name: "date")
    final int? date;
    @JsonKey(name: "value")
    final double? value;
    @JsonKey(name: "colorCode")
    final String? colorCode;

    WeightStatisticRecord({
        this.date,
        this.value,
        this.colorCode,
    });

    factory WeightStatisticRecord.fromJson(Map<String, dynamic> json) => _$WeightStatisticRecordFromJson(json);

    Map<String, dynamic> toJson() => _$WeightStatisticRecordToJson(this);
}

@JsonSerializable()
class WeightSafe {
    @JsonKey(name: "safeWeightFrom")
    final double? safeWeightFrom;
    @JsonKey(name: "safeWeightTo")
    final double? safeWeightTo;
    @JsonKey(name: "safeDateFrom")
    final int? safeDateFrom;
    @JsonKey(name: "week")
    final int? week;
    @JsonKey(name: "length")
    final int? length;

    WeightSafe({
        this.safeWeightFrom,
        this.safeWeightTo,
        this.safeDateFrom,
        this.week,
        this.length,
    });

    factory WeightSafe.fromJson(Map<String, dynamic> json) => _$WeightSafeFromJson(json);

    Map<String, dynamic> toJson() => _$WeightSafeToJson(this);
}