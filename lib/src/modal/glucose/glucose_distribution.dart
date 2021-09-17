import 'package:medical/src/app_setting/app_setting.dart';
import 'package:meta/meta.dart';

class DistributionModel {
  final double lowest;
  final String lowestColor;
  final String lowestId;
  final double average;
  final String averageColor;
  final double highest;
  final String highestColor;
  final String highestId;
  final int veryLowCount;
  final String veryLowColor;
  final AttributeColorModel veryLowAttributesColor;
  final int lowCount;
  final String lowColor;
  final AttributeColorModel lowAttributesColor;
  final int goodCount;
  final String goodColor;
  final AttributeColorModel goodAttributesColor;
  final int highCount;
  final String highColor;
  final AttributeColorModel highAttributesColor;
  final int veryHighCount;
  final String veryHighColor;
  final AttributeColorModel veryHighAttributesColor;
  final int totalCount;

  DistributionModel({
    @required this.lowest,
    @required this.lowestColor,
    @required this.lowestId,
    @required this.average,
    @required this.averageColor,
    @required this.highest,
    @required this.highestColor,
    @required this.highestId,
    @required this.veryLowCount,
    @required this.veryLowColor,
    @required this.veryLowAttributesColor,
    @required this.lowCount,
    @required this.lowColor,
    @required this.lowAttributesColor,
    @required this.goodCount,
    @required this.goodColor,
    @required this.goodAttributesColor,
    @required this.highCount,
    @required this.highColor,
    @required this.highAttributesColor,
    @required this.veryHighCount,
    @required this.veryHighColor,
    @required this.veryHighAttributesColor,
    @required this.totalCount,
  });
  @override
  factory DistributionModel.fromJson(Map<String, dynamic> json) {
    return DistributionModel(
      lowest: AppSettings.userInfo.glucoseUnit == 1
          ? json['lowest']
          : json['lowestMmoll'],
      lowestColor: json['lowestColor'],
      lowestId: json['lowestId'],
      average: AppSettings.userInfo.glucoseUnit == 1
          ? json['average']
          : json['averageMmoll'],
      averageColor: json['averageColor'],
      highest: AppSettings.userInfo.glucoseUnit == 1
          ? json['highest']
          : json['highestMmoll'],
      highestColor: json['highestColor'],
      highestId: json['highestId'],
      veryLowCount: json['veryLowCount'],
      veryLowColor: json['veryLowColor'],
      veryLowAttributesColor:
          AttributeColorModel.fromJson(json['veryLowAttributesColor']),
      lowCount: json['lowCount'],
      lowColor: json['lowColor'],
      lowAttributesColor:
          AttributeColorModel.fromJson(json['lowAttributesColor']),
      goodCount: json['goodCount'],
      goodColor: json['goodColor'],
      goodAttributesColor:
          AttributeColorModel.fromJson(json['goodAttributesColor']),
      highCount: json['highCount'],
      highColor: json['highColor'],
      highAttributesColor:
          AttributeColorModel.fromJson(json['highAttributesColor']),
      veryHighCount: json['veryHighCount'],
      veryHighColor: json['veryHighColor'],
      veryHighAttributesColor:
          AttributeColorModel.fromJson(json['veryHighAttributesColor']),
      totalCount: json['totalCount'],
    );
  }
}

class AttributeColorModel {
  final String fontColor;
  final String borderColor;
  final String backgroundColor;

  AttributeColorModel(
      {@required this.fontColor,
      @required this.borderColor,
      @required this.backgroundColor});
  @override
  factory AttributeColorModel.fromJson(Map<String, dynamic> json) {
    return AttributeColorModel(
        fontColor: json['fontColor'],
        borderColor: json['borderColor'],
        backgroundColor: json['backgroundColor']);
  }
}
