import 'package:meta/meta.dart';
@immutable
class BloodPressureStatisticModel {
  final int? systolicLowest;
  final int? systolicHighest;
  final int? systolicAverage;
  final int? diastolicLowest;
  final int? diastolicHighest;
  final int? diastolicAverage;
  final int? pulseRateLowest;
  final int? pulseRateHighest;
  final int? pulseRateAverage;
  final String? averageColor;
  final String? highestColor;
  final String? lowestColor;

  const BloodPressureStatisticModel({
    required this.systolicLowest,
    required this.systolicHighest,
    required this.systolicAverage,
    required this.diastolicLowest,
    required this.diastolicHighest,
    required this.diastolicAverage,
    required this.pulseRateLowest,
    required this.pulseRateHighest,
    required this.pulseRateAverage,
    required this.averageColor,
    required this.highestColor,
    required this.lowestColor
  });
  @override
  factory BloodPressureStatisticModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureStatisticModel(
      systolicLowest: json['systolicLowest'],
      systolicHighest: json['systolicHighest'],
      systolicAverage: json['systolicAverage'],
      diastolicLowest: json['diastolicLowest'],
      diastolicHighest: json['diastolicHighest'],
      diastolicAverage: json['diastolicAverage'],
      pulseRateLowest: json['pulseRateLowest'],
      pulseRateHighest: json['pulseRateHighest'],
      pulseRateAverage: json['pulseRateAverage'],
      averageColor: json['averageColor'],
      highestColor: json['highestColor'],
      lowestColor: json['lowestColor']
    );
  }

  static List<BloodPressureStatisticModel> toList(List<dynamic> items) {
    return items.map((item) => BloodPressureStatisticModel.fromJson(item)).toList();
  }
}
