import 'package:json_annotation/json_annotation.dart';

part 'bmi_statistical_response.g.dart';

@JsonSerializable()
class BmiStatisticalResponse {
    @JsonKey(name: "value")
    final int? value;
    @JsonKey(name: "weight")
    final int? weight;
    @JsonKey(name: "height")
    final int? height;
    @JsonKey(name: "currentLedend")
    final End? currentLedend;
    @JsonKey(name: "legends")
    final List<End>? legends;

    BmiStatisticalResponse({
        this.value,
        this.weight,
        this.height,
        this.currentLedend,
        this.legends,
    });

    factory BmiStatisticalResponse.fromJson(Map<String, dynamic> json) => _$BmiStatisticalResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiStatisticalResponseToJson(this);
}

@JsonSerializable()
class End {
    @JsonKey(name: "text")
    final String? text;
    @JsonKey(name: "colorCode")
    final String? colorCode;
    @JsonKey(name: "backgroundColorCode")
    final String? backgroundColorCode;
    @JsonKey(name: "textcolorCode")
    final String? textcolorCode;

    End({
        this.text,
        this.colorCode,
        this.backgroundColorCode,
        this.textcolorCode,
    });

    factory End.fromJson(Map<String, dynamic> json) => _$EndFromJson(json);

    Map<String, dynamic> toJson() => _$EndToJson(this);
}