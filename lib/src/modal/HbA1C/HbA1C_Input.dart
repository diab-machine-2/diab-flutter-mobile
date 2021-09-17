import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

class InputHbA1CModel {
  final String id;
  final int date;
  final String type;
  final double hbA1C;
  final double glucose;
  final String unit;
  final String description;
  final String color;
  final String fontColor;
  final String backgroundColor;
  final String borderColor;
  final String percentColor;
  final List<ImagesModel> images;

  InputHbA1CModel({
    @required this.id,
    @required this.date,
    @required this.type,
    @required this.hbA1C,
    @required this.glucose,
    @required this.unit,
    @required this.description,
    @required this.color,
    @required this.fontColor,
    @required this.backgroundColor,
    @required this.borderColor,
    @required this.percentColor,
    @required this.images,
  });
  @override
  factory InputHbA1CModel.fromJson(Map<String, dynamic> json) {
    return InputHbA1CModel(
        id: json['id'],
        date: json['date'],
        type: json['type'],
        hbA1C: json['hbA1C'],
        glucose: json['glucose'],
        unit: json['unit'],
        description: json['description'],
        color: json['color'],
        fontColor: json['fontColor'],
        backgroundColor: json['backgroundColor'],
        borderColor: json['borderColor'],
        percentColor: json['percentColor'],
        images: ImagesModel.toList(json['images']));
  }
  static List<InputHbA1CModel> toList(List<dynamic> items) {
    return items.map((item) => InputHbA1CModel.fromJson(item)).toList();
  }
}

// class ImageHbA1CModel {
//   final String id;
//   final int url;

//   ImageHbA1CModel({
//     @required this.id,
//     @required this.url,
//   });
//   @override
//   factory ImageHbA1CModel.fromJson(Map<String, dynamic> json) {
//     return ImageHbA1CModel(
//       id: json['id'],
//       url: json['url'],
//     );
//   }
//   static List<ImageHbA1CModel> toList(List<dynamic> items) {
//     return items.map((item) => ImageHbA1CModel.fromJson(item)).toList();
//   }
// }
