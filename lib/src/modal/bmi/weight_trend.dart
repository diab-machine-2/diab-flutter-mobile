import 'package:meta/meta.dart';

@immutable
class TrendWeightModel {
  final double? safeWeightFrom;
  final double? safeWeightTo;
  final double? current;
  final double? lowest;
  final double? highest;
  final double? goal;
  final String? message;
  final String? iconUrl;
  final List<WeightSafes>? weightSafes;
  final List<TrendItemWeightModel>? trendItems;

  const TrendWeightModel({
    required this.safeWeightFrom,
    required this.safeWeightTo,
    required this.current,
    required this.lowest,
    required this.highest,
    required this.goal,
    required this.message,
    required this.iconUrl,
    required this.trendItems,
    required this.weightSafes,
  });
  @override
  factory TrendWeightModel.fromJson(Map<String, dynamic> json) {
    List<WeightSafes> weightSafes = [];
    if (json['weightSafes'] != null) {
      json['weightSafes'].forEach((v) {
        weightSafes.add(new WeightSafes.fromJson(v));
      });
    }

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
          : TrendItemWeightModel.toList(json['trendItems']).reversed.toList(),
      weightSafes: weightSafes,
    );
  }

  static List<TrendWeightModel> toList(List<dynamic> items) {
    return items.map((item) => TrendWeightModel.fromJson(item)).toList();
  }
}

class WeightSafes {
  late num safeWeightFrom;
  late num safeWeightTo;
  late num safeDateFrom;
  late int week;
  late int length;

  WeightSafes(
      {required this.safeWeightFrom,
      required this.safeWeightTo,
      required this.safeDateFrom,
      required this.week});

  WeightSafes.fromJson(Map<String, dynamic> json) {
    safeWeightFrom = json['safeWeightFrom'];
    safeWeightTo = json['safeWeightTo'];
    safeDateFrom = json['safeDateFrom'];
    week = json['week'];
    length = json['length'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['safeWeightFrom'] = this.safeWeightFrom;
    data['safeWeightTo'] = this.safeWeightTo;
    data['safeDateFrom'] = this.safeDateFrom;
    data['week'] = this.week;
    data['length'] = this.length;
    return data;
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
