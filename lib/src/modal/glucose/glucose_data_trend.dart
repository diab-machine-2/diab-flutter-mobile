import 'package:medical/src/modal/glucose/glucose_trend.dart';
import 'package:meta/meta.dart';
@immutable
class TrendDataModel {
  final TrendItemsModel trendItems;
  final GoodRangeModel goodRange;

  const TrendDataModel({required this.trendItems, required this.goodRange});
  @override
  factory TrendDataModel.fromJson(Map<String, dynamic> json) {
    return TrendDataModel(
        trendItems: TrendItemsModel.fromJson(json['trendItems']),
        goodRange: GoodRangeModel.fromJson(json['goodRange']));
  }
  static List<TrendDataModel> toList(List<dynamic> items) {
    return items.map((item) => TrendDataModel.fromJson(item)).toList();
  }
}

class TrendItemsModel {
  final int? total;
  final int? page;
  final int? size;
  final List<TrendItemModel> items;

  TrendItemsModel(
      {required this.total,
      required this.page,
      required this.size,
      required this.items});
  @override
  factory TrendItemsModel.fromJson(Map<String, dynamic> json) {
    return TrendItemsModel(
        total: json['total'],
        page: json['page'],
        size: json['size'],
        items: TrendItemModel.toList(json['items']).reversed.toList());
  }
}

class GoodRangeModel {
  final double? key;
  final double? value;

  GoodRangeModel({required this.key, required this.value});
  @override
  factory GoodRangeModel.fromJson(Map<String, dynamic> json) {
    return GoodRangeModel(
      key: json['key'],
      value: json['value'],
    );
  }
}
