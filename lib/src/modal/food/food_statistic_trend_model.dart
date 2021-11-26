import 'package:meta/meta.dart';
@immutable
class FoodTrendModel {
  final EnergyTrendModel energyChart;
  final EnergyTrendModel carbChart;

  const FoodTrendModel({required this.carbChart, required this.energyChart});
  @override
  factory FoodTrendModel.fromJson(Map<String, dynamic> json) {
    return FoodTrendModel(
        energyChart: EnergyTrendModel.fromJson(json['energyChart']),
        carbChart: EnergyTrendModel.fromJson(json['carbChart']));
  }

  static List<FoodTrendModel> toList(List<dynamic> items) {
    return items.map((item) => FoodTrendModel.fromJson(item)).toList();
  }
}

class EnergyTrendModel {
  final double? avgValue;
  final List<EnergyTrendItemModel> items;

  EnergyTrendModel({required this.avgValue, required this.items});
  @override
  factory EnergyTrendModel.fromJson(Map<String, dynamic> json) {
    return EnergyTrendModel(
        avgValue: json['avgValue'],
        items: EnergyTrendItemModel.toList(json['items']).reversed.toList());
  }

  static List<EnergyTrendModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyTrendModel.fromJson(item)).toList();
  }
}

class EnergyTrendItemModel {
  final int? date;
  final double? value;
  final String? colorCode;

  EnergyTrendItemModel(
      {required this.date, required this.value, required this.colorCode});
  @override
  factory EnergyTrendItemModel.fromJson(Map<String, dynamic> json) {
    return EnergyTrendItemModel(
        date: json['date'], value: json['value'], colorCode: json['colorCode']);
  }

  static List<EnergyTrendItemModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyTrendItemModel.fromJson(item)).toList();
  }
}
