import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

class InputBmiModel {
  final int? date;
  final double? weight;
  final double? waits;
  final double? height;
  final String? note;
  final String? timeFrameId;
  final String? bmiId;
  final String? waistId;

  final List<ImagesModel> images;

  InputBmiModel({
    required this.date,
    required this.weight,
    required this.waits,
    required this.height,
    required this.note,
    required this.timeFrameId,
    required this.bmiId,
    required this.waistId,
    required this.images,
  });
  @override
  factory InputBmiModel.fromJson(Map<String, dynamic> json) {
    return InputBmiModel(
        date: json['date'],
        weight: json['weight'],
        waits: json['waits'],
        height: json['height'],
        note: json['note'],
        timeFrameId: json['timeFrameId'],
        bmiId: json['bmiId'],
        waistId: json['waistId'],
        images: ImagesModel.toList(json['images']));
  }

  static List<InputBmiModel> toList(List<dynamic> items) {
    return items.map((item) => InputBmiModel.fromJson(item)).toList();
  }
}
