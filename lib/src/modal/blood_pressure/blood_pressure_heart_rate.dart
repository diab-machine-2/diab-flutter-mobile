import 'package:meta/meta.dart';
@immutable
class BloodPressureHeartRateModel {
  final double? systolicLowest;
  final double? systolicHighest;
  final double? systolicAverage;
  final double? diastolicLowest;
  final String? diastolicLowestId;
  final double? diastolicHighest;
  final String? diastolicHighestId;
  final double? diastolicAverage;
  final double? pulseRateLowest;
  final String? pulseRateLowestId;
  final double? pulseRateHighest;
  final String? pulseRateHighestId;
  final double? pulseRateAverage;
  final String? averageColor;
  final String? highestColor;
  final String? lowestColor;

  const BloodPressureHeartRateModel({
    required this.systolicLowest,
    required this.systolicHighest,
    required this.systolicAverage,
    required this.diastolicLowest,
    required this.diastolicLowestId,
    required this.diastolicHighest,
    required this.diastolicHighestId,
    required this.diastolicAverage,
    required this.pulseRateLowest,
    required this.pulseRateLowestId,
    required this.pulseRateHighest,
    required this.pulseRateHighestId,
    required this.pulseRateAverage,
    required this.averageColor,
    required this.highestColor,
    required this.lowestColor,
  });
  @override
  factory BloodPressureHeartRateModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureHeartRateModel(
      systolicLowest: json['systolicLowest'],
      systolicHighest: json['systolicHighest'],
      systolicAverage: json['systolicAverage'],
      diastolicLowest: json['diastolicLowest'],
      diastolicLowestId: json['diastolicLowestId'],
      diastolicHighest: json['diastolicHighest'],
      diastolicHighestId: json['diastolicHighestId'],
      diastolicAverage: json['diastolicAverage'],
      pulseRateLowest: json['pulseRateLowest'],
      pulseRateLowestId: json['pulseRateLowestId'],
      pulseRateHighest: json['pulseRateHighest'],
      pulseRateHighestId: json['pulseRateHighestId'],
      pulseRateAverage: json['pulseRateAverage'],
      averageColor: json['averageColor'],
      highestColor: json['highestColor'],
      lowestColor: json['lowestColor'],
    );
  }

  static List<BloodPressureHeartRateModel> toList(List<dynamic> items) {
    return items
        .map((item) => BloodPressureHeartRateModel.fromJson(item))
        .toList();
  }
}
