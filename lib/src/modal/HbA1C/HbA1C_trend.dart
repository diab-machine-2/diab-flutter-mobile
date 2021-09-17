import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class TrendModel {
  final TrendItemModel trendItems;
  final List legends;

  TrendModel({
    @required this.trendItems,
    @required this.legends,
  });
  @override
  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
      trendItems: json['trendItems'] == null
          ? null
          : TrendItemModel.fromJson(json['trendItems']),
      legends: json['legends'],
    );
  }
}

class TrendItemModel {
  final int total;
  final int page;
  final int size;
  final List<HbA1CModel> items;

  TrendItemModel({
    @required this.total,
    @required this.page,
    @required this.size,
    @required this.items,
  });
  @override
  factory TrendItemModel.fromJson(Map<String, dynamic> json) {
    return TrendItemModel(
        total: json['total'],
        page: json['page'],
        size: json['size'],
        items: HbA1CModel.toList(json['items']).reversed.toList());
  }
}

class HbA1CModel {
  final double hbA1C;
  final int date;
  final String type;
  final String color;
  final String fontColor;
  final String backgroundColor;

  HbA1CModel({
    @required this.hbA1C,
    @required this.date,
    @required this.type,
    @required this.color,
    @required this.fontColor,
    @required this.backgroundColor,
  });
  @override
  factory HbA1CModel.fromJson(Map<String, dynamic> json) {
    return HbA1CModel(
      hbA1C: json['hbA1C'],
      date: json['date'],
      type: json['type'],
      color: json['color'],
      fontColor: json['fontColor'],
      backgroundColor: json['backgroundColor'],
    );
  }

  static List<HbA1CModel> toList(List<dynamic> items) {
    return items.map((item) => HbA1CModel.fromJson(item)).toList();
  }
}
