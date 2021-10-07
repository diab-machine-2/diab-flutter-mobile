import 'package:medical/src/modal/food/food_statistic_diet_model.dart';
import 'package:meta/meta.dart';

class FoodDistributeModel {
  final List<LegendModel> legends;
  final List<EnergyItemModel> energyChart;
  final List<EnergyItemModel> carbChart;

  FoodDistributeModel(
      {required this.legends,
      required this.energyChart,
      required this.carbChart});
  @override
  factory FoodDistributeModel.fromJson(Map<String, dynamic> json) {
    return FoodDistributeModel(
        legends: LegendModel.toList(json['legends']),
        energyChart: EnergyItemModel.toList(json['energyChart']['details']),
        carbChart: EnergyItemModel.toList(json['carbChart']['details']));
  }

  static List<FoodDistributeModel> toList(List<dynamic> items) {
    return items.map((item) => FoodDistributeModel.fromJson(item)).toList();
  }
}

class EnergyItemModel {
  final String? text;
  final double? value;
  final double? percentValue;
  final String? colorCode;

  EnergyItemModel(
      {required this.text,
      required this.value,
      required this.percentValue,
      required this.colorCode});
  @override
  factory EnergyItemModel.fromJson(Map<String, dynamic> json) {
    return EnergyItemModel(
        text: json['text'],
        value: json['value'],
        percentValue: json['percentValue'],
        colorCode: json['colorCode']);
  }

  static List<EnergyItemModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyItemModel.fromJson(item)).toList();
  }
}
