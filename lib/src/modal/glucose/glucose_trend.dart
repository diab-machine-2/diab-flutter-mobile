import 'package:medical/src/app_setting/app_setting.dart';
import 'package:meta/meta.dart';

class TrendItemModel {
  final int? date;
  final List<TrendModel> subTrends;

  TrendItemModel({required this.date, required this.subTrends});
  @override
  factory TrendItemModel.fromJson(Map<String, dynamic> json) {
    return TrendItemModel(
        date: json['date'],
        subTrends: TrendModel.toList(json['subTrends']).reversed.toList());
  }

  static List<TrendItemModel> toList(List<dynamic> items) {
    return items.map((item) => TrendItemModel.fromJson(item)).toList();
  }
}

class TrendModel {
  final double? glucose;
  final String? type;
  final String? color;

  TrendModel({
    required this.glucose,
    required this.type,
    required this.color,
  });
  @override
  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
      glucose: AppSettings.userInfo!.glucoseUnit == 1
          ? json['glucose']
          : json['glucoseMmoll'],
      type: json['type'],
      color: json['color'],
    );
  }

  static List<TrendModel> toList(List<dynamic> items) {
    return items.map((item) => TrendModel.fromJson(item)).toList();
  }
}
