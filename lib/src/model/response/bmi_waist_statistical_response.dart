import 'package:json_annotation/json_annotation.dart';

import 'package:medical/src/model/response/base/response.dart';

part 'bmi_waist_statistical_response.g.dart';

@JsonSerializable()
class BmiWaistStatisticalResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final BmiWaistStatistical? data;

    BmiWaistStatisticalResponse({
        this.meta,
        this.data,
    });

    factory BmiWaistStatisticalResponse.fromJson(Map<String, dynamic> json) => _$BmiWaistStatisticalResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiWaistStatisticalResponseToJson(this);
}

@JsonSerializable()
class BmiWaistStatistical {
    @JsonKey(name: "current")
    final int? current;
    @JsonKey(name: "lowest")
    final int? lowest;
    @JsonKey(name: "highest")
    final int? highest;
    @JsonKey(name: "goal")
    final int? goal;
    @JsonKey(name: "message")
    final String? message;
    @JsonKey(name: "iconUrl")
    final String? iconUrl;
    @JsonKey(name: "trendItems")
    final List<TrendItem>? trendItems;

    BmiWaistStatistical({
        this.current,
        this.lowest,
        this.highest,
        this.goal,
        this.message,
        this.iconUrl,
        this.trendItems,
    });

    factory BmiWaistStatistical.fromJson(Map<String, dynamic> json) => _$BmiWaistStatisticalFromJson(json);

    Map<String, dynamic> toJson() => _$BmiWaistStatisticalToJson(this);
}

@JsonSerializable()
class TrendItem {
    @JsonKey(name: "date")
    final int? date;
    @JsonKey(name: "value")
    final int? value;
    @JsonKey(name: "colorCode")
    final String? colorCode;

    TrendItem({
        this.date,
        this.value,
        this.colorCode,
    });

    factory TrendItem.fromJson(Map<String, dynamic> json) => _$TrendItemFromJson(json);

    Map<String, dynamic> toJson() => _$TrendItemToJson(this);
}