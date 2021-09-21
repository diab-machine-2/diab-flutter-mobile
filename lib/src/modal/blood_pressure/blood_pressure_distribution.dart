import 'package:meta/meta.dart';

class BloodPressureDistributionModel {
  final int? total;
  final int? low;
  final String? lowColor;
  final String? lowFontColor;
  final int? normal;
  final String? normalColor;
  final String? normalFontColor;
  final int? preIncrease;
  final String? preIncreaseColor;
  final String? preIncreaseFontColor;
  final int? increaseLevelOne;
  final String? increaseLevelOneColor;
  final String? increaseLevelOneFontColor;
  final int? increaseLevelTwo;
  final String? increaseLevelTwoColor;
  final String? increaseLevelTwoFontColor;
  final int? increaseLevelThree;
  final String? increaseLevelThreeColor;
  final String? increaseLevelThreeFontColor;

  BloodPressureDistributionModel({
    required this.total,
    required this.low,
    required this.lowColor,
    required this.lowFontColor,
    required this.normal,
    required this.normalColor,
    required this.normalFontColor,
    required this.preIncrease,
    required this.preIncreaseColor,
    required this.preIncreaseFontColor,
    required this.increaseLevelOne,
    required this.increaseLevelOneColor,
    required this.increaseLevelOneFontColor,
    required this.increaseLevelTwo,
    required this.increaseLevelTwoColor,
    required this.increaseLevelTwoFontColor,
    required this.increaseLevelThree,
    required this.increaseLevelThreeColor,
    required this.increaseLevelThreeFontColor,
  });
  @override
  factory BloodPressureDistributionModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureDistributionModel(
        total: json['total'],
        low: json['low'],
        lowColor: json['lowColor'],
        lowFontColor: json['lowFontColor'],
        normal: json['normal'],
        normalColor: json['normalColor'],
        normalFontColor: json['normalFontColor'],
        preIncrease: json['preIncrease'],
        preIncreaseColor: json['preIncreaseColor'],
        preIncreaseFontColor: json['preIncreaseFontColor'],
        increaseLevelOne: json['increaseLevelOne'],
        increaseLevelOneColor: json['increaseLevelOneColor'],
        increaseLevelOneFontColor: json['increaseLevelOneFontColor'],
        increaseLevelTwo: json['increaseLevelTwo'],
        increaseLevelTwoColor: json['increaseLevelTwoColor'],
        increaseLevelTwoFontColor: json['increaseLevelTwoFontColor'],
        increaseLevelThree: json['increaseLevelThree'],
        increaseLevelThreeColor: json['increaseLevelThreeColor'],
        increaseLevelThreeFontColor: json['increaseLevelThreeFontColor']);
  }

  static List<BloodPressureDistributionModel> toList(List<dynamic> items) {
    return items
        .map((item) => BloodPressureDistributionModel.fromJson(item))
        .toList();
  }
}
