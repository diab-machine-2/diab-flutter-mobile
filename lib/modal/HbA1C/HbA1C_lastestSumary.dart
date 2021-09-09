import 'package:flutter/material.dart';
import 'package:medical/modal/base/images.dart';
import 'package:meta/meta.dart';

class LastestSummaryModel {
  final double hbA1C;
  final double differentPercentage;
  final String description;
  final String color;
  final String status;
  final String fontColor;
  final String backgroundColor;
  final String borderColor;
  final String percentColor;
  final ImagesModel imageUrl;

  LastestSummaryModel(
      {@required this.hbA1C,
      @required this.differentPercentage,
      @required this.description,
      @required this.color,
      @required this.status,
      @required this.fontColor,
      @required this.backgroundColor,
      @required this.borderColor,
      @required this.percentColor,
      @required this.imageUrl});
  @override
  factory LastestSummaryModel.fromJson(Map<String, dynamic> json) {
    return LastestSummaryModel(
        hbA1C: json['hbA1C'],
        differentPercentage: json['differentPercentage'],
        description: json['description'],
        color: json['color'],
        status: json['status'],
        fontColor: json['fontColor'],
        backgroundColor: json['backgroundColor'],
        borderColor: json['borderColor'],
        percentColor: json['percentColor'],
        imageUrl: json['imageUrl'] == null
            ? null
            : ImagesModel.fromJson(json['imageUrl']));
  }
}
