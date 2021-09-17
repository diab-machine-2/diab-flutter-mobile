import 'package:meta/meta.dart';

class TrendBmiModel {
  final double value;
  final CurrentLedendModel currentLedend;

  final List<LegendsModel> legends;

  TrendBmiModel({
    @required this.value,
    @required this.currentLedend,
    @required this.legends,
  });
  @override
  factory TrendBmiModel.fromJson(Map<String, dynamic> json) {
    return TrendBmiModel(
        value: json['value'],
        currentLedend: json['currentLedend'] == null
            ? null
            : CurrentLedendModel.fromJson(json['currentLedend']),
        legends: json['legends'] == null
            ? []
            : LegendsModel.toList(json['legends']).toList());
  }

  static List<TrendBmiModel> toList(List<dynamic> items) {
    return items.map((item) => TrendBmiModel.fromJson(item)).toList();
  }
}

class LegendsModel {
  final String text;
  final String colorCode;

  LegendsModel({
    @required this.text,
    @required this.colorCode,
  });
  @override
  factory LegendsModel.fromJson(Map<String, dynamic> json) {
    return LegendsModel(
      text: json['text'],
      colorCode: json['colorCode'],
    );
  }

  static List<LegendsModel> toList(List<dynamic> items) {
    return items.map((item) => LegendsModel.fromJson(item)).toList();
  }
}

class CurrentLedendModel {
  final String text;
  final String colorCode;
  final String textcolorCode;
  final String backgroundColorCode;

  CurrentLedendModel({
    @required this.text,
    @required this.colorCode,
    @required this.textcolorCode,
    @required this.backgroundColorCode,
  });
  @override
  factory CurrentLedendModel.fromJson(Map<String, dynamic> json) {
    return CurrentLedendModel(
      text: json['text'],
      colorCode: json['colorCode'],
      textcolorCode: json['textcolorCode'],
      backgroundColorCode: json['backgroundColorCode'],
    );
  }
}
