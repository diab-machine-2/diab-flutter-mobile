import 'package:meta/meta.dart';
@immutable
class FoodDietModel {
  final List<LegendModel> legends;
  final List<EnergyModel> energyChart;
  final List<EnergyModel> carbChart;

  const FoodDietModel(
      {required this.legends,
      required this.energyChart,
      required this.carbChart});
  @override
  factory FoodDietModel.fromJson(Map<String, dynamic> json) {
    return FoodDietModel(
        legends: LegendModel.toList(json['legends']),
        energyChart:
            EnergyModel.toList(json['energyChart']['items']).reversed.toList(),
        carbChart:
            EnergyModel.toList(json['carbChart']['items']).reversed.toList());
  }

  static List<FoodDietModel> toList(List<dynamic> items) {
    return items.map((item) => FoodDietModel.fromJson(item)).toList();
  }
}

class LegendModel {
  final String? text;
  final String? colorCode;

  LegendModel({required this.text, required this.colorCode});
  @override
  factory LegendModel.fromJson(Map<String, dynamic> json) {
    return LegendModel(text: json['text'], colorCode: json['colorCode']);
  }

  static List<LegendModel> toList(List<dynamic> items) {
    return items.map((item) => LegendModel.fromJson(item)).toList();
  }
}

class EnergyModel {
  final List<EnergyItemModel> details;
  final int? date;
  final double? value;
  final String? colorCode;

  EnergyModel(
      {required this.details,
      required this.date,
      required this.value,
      required this.colorCode});
  @override
  factory EnergyModel.fromJson(Map<String, dynamic> json) {
    return EnergyModel(
        details: EnergyItemModel.toList(json['details']),
        date: json['date'],
        value: json['value'],
        colorCode: json['colorCode']);
  }

  static List<EnergyModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyModel.fromJson(item)).toList();
  }
}

class EnergyItemModel {
  final double? value;
  final double? percentValue;
  final String? colorCode;

  EnergyItemModel(
      {required this.value,
      required this.percentValue,
      required this.colorCode});
  @override
  factory EnergyItemModel.fromJson(Map<String, dynamic> json) {
    return EnergyItemModel(
        value: json['value'],
        percentValue: json['percentValue'] == 'NaN' ? 0 : json['percentValue'],
        colorCode: json['colorCode']);
  }

  static List<EnergyItemModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyItemModel.fromJson(item)).toList();
  }
}
