import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_item_model.dart';
import 'package:meta/meta.dart';

class EmotionStatisticModel {
  final String note;
  final ImagesModel noteIcon;
  final ImagesModel noteImage;
  final List<EmotionStatisticItemModel> emotions;

  EmotionStatisticModel(
      {@required this.note,
      @required this.noteIcon,
      @required this.noteImage,
      @required this.emotions});
  @override
  factory EmotionStatisticModel.fromJson(Map<String, dynamic> json) {
    return EmotionStatisticModel(
        note: json['note'],
        noteIcon: json['noteIcon'] == null
            ? null
            : ImagesModel.fromJson(json['noteIcon']),
        noteImage: json['noteImage'] == null
            ? null
            : ImagesModel.fromJson(json['noteImage']),
        emotions: EmotionStatisticItemModel.toList(json['emotions']));
  }
  static List<EmotionStatisticModel> toList(List<dynamic> items) {
    return items.map((item) => EmotionStatisticModel.fromJson(item)).toList();
  }
}
