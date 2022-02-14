import 'package:meta/meta.dart';
@immutable
class BloodPressureTrendModel {
  final TrendModel trendItems;
  final List<String>? legends;
  final List<String>? colors;

  const BloodPressureTrendModel(
      {required this.trendItems,
      required this.legends,
      required this.colors});
  @override
  factory BloodPressureTrendModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureTrendModel(
        trendItems: TrendModel.fromJson(json['trendItems']),
        legends: json['legends'].cast<String>(),
        colors: json['colors'].cast<String>());
  }

  static List<BloodPressureTrendModel> toList(List<dynamic> items) {
    return items.map((item) => BloodPressureTrendModel.fromJson(item)).toList();
  }
}

class TrendModel {
  final int? total;
  final int? page;
  final int? size;
  final List<TrendItemModel> items;

  TrendModel(
      {required this.total,
      required this.page,
      required this.size,
      required this.items});
  @override
  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
        total: json['total'],
        page: json['page'],
        size: json['size'],
        items: TrendItemModel.toList(json['items'].reversed.toList()));
  }
}

class TrendItemModel {
  final int? date;
  final List<SubTrendItemModel> subTrendItems;

  TrendItemModel({required this.date, required this.subTrendItems});
  @override
  factory TrendItemModel.fromJson(Map<String, dynamic> json) {
    return TrendItemModel(
        date: json['date'],
        subTrendItems:
            SubTrendItemModel.toList(json['subTrendItems']).reversed.toList());
  }

  static List<TrendItemModel> toList(List<dynamic> items) {
    return items.map((item) => TrendItemModel.fromJson(item)).toList();
  }
}

class SubTrendItemModel {
  final double? systolic;
  final double? diastolic;
  final double? pulseRate;

  SubTrendItemModel(
      {required this.systolic,
      required this.diastolic,
      required this.pulseRate});
  @override
  factory SubTrendItemModel.fromJson(Map<String, dynamic> json) {
    return SubTrendItemModel(
        systolic: json['systolic'],
        diastolic: json['diastolic'],
        pulseRate: json['pulseRate']);
  }

  static List<SubTrendItemModel> toList(List<dynamic> items) {
    return items.map((item) => SubTrendItemModel.fromJson(item)).toList();
  }
}
