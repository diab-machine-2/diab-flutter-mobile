import 'package:meta/meta.dart';

class TrendWeightModel {
  final double? safeWeightFrom;
  final double? safeWeightTo;
  final double? current;
  final double? lowest;
  final double? highest;
  final double? goal;
  final String? message;
  final String? iconUrl;
  final List<TrendItemWeightModel>? trendItems;

  TrendWeightModel({
    required this.safeWeightFrom,
    required this.safeWeightTo,
    required this.current,
    required this.lowest,
    required this.highest,
    required this.goal,
    required this.message,
    required this.iconUrl,
    required this.trendItems,
  });
  @override
  factory TrendWeightModel.fromJson(Map<String, dynamic> json) {
    return TrendWeightModel(
        safeWeightFrom: json['safeWeightFrom'],
        safeWeightTo: json['safeWeightTo'],
        current: json['current'],
        lowest: json['lowest'],
        highest: json['highest'],
        goal: json['goal'] == null ? null : json['goal'],
        message: json['message'] == null ? null : json['message'],
        iconUrl: json['iconUrl'] == null ? null : json['iconUrl'],
        trendItems: json['trendItems'] == null
            ? null
            : TrendItemWeightModel.toList(json['trendItems'])
                .reversed
                .toList());
  }

  static List<TrendWeightModel> toList(List<dynamic> items) {
    return items.map((item) => TrendWeightModel.fromJson(item)).toList();
  }
}

class TrendItemWeightModel {
  final double? value;
  final int? date;
  final String? colorCode;

  TrendItemWeightModel({
    required this.value,
    required this.date,
    required this.colorCode,
  });
  @override
  factory TrendItemWeightModel.fromJson(Map<String, dynamic> json) {
    return TrendItemWeightModel(
      value: json['value'],
      date: json['date'],
      colorCode: json['colorCode'],
    );
  }

  static List<TrendItemWeightModel> toList(List<dynamic> items) {
    return items.map((item) => TrendItemWeightModel.fromJson(item)).toList();
  }
}
