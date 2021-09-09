import 'package:medical/modal/base/images.dart';
import 'package:meta/meta.dart';

class InputWeightModel {
  final String id;
  final double weight;
  final double waist;
  final int date;
  final double height;
  final double bmi;
  final String note;
  final String timeFrameId;
  final String timeFrameText;
  final String bmiId;
  final String bmiText;
  final String waistId;
  final String bmiColorCode;
  final String bmiTextColorCode;
  final String bmiBackgroundColorCode;
  final String waistColorCode;
  final List<ImagesModel> images;

  InputWeightModel({
    @required this.id,
    @required this.weight,
    @required this.waist,
    @required this.height,
    @required this.date,
    @required this.bmi,
    @required this.note,
    @required this.timeFrameId,
    @required this.timeFrameText,
    @required this.bmiId,
    @required this.bmiText,
    @required this.waistId,
    @required this.bmiColorCode,
    @required this.bmiTextColorCode,
    @required this.bmiBackgroundColorCode,
    @required this.waistColorCode,
    @required this.images,
  });
  @override
  factory InputWeightModel.fromJson(Map<String, dynamic> json) {
    return InputWeightModel(
        id: json['id'],
        weight: json['weight'],
        waist: json['waist'],
        height: json['height'],
        date: json['date'],
        bmi: json['bmi'],
        note: json['note'],
        timeFrameId: json['timeFrameId'],
        timeFrameText: json['timeFrameText'],
        bmiId: json['bmiId'],
        bmiText: json['bmiText'],
        waistId: json['waistId'],
        bmiColorCode: json['bmiColorCode'],
        bmiTextColorCode: json['bmiTextColorCode'],
        bmiBackgroundColorCode: json['bmiBackgroundColorCode'],
        waistColorCode: json['waistColorCode'],
        images: ImagesModel.toList(json['images']));
  }

  static List<InputWeightModel> toList(List<dynamic> items) {
    return items.map((item) => InputWeightModel.fromJson(item)).toList();
  }
}
