import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/emotion/activity_model.dart';
import 'package:medical/src/modal/emotion/symptom_model.dart';
import 'package:meta/meta.dart';

class InputEmotionModel {
  final String? id;
  final int? date;
  final int? emotionScore;
  final String? emotionId;
  final String? emotionText;
  final String? note;
  final String? timeFrameId;
  final String? timeFrameText;
  final String? colorCode;
  final String? backgroundColorCode;
  final ImagesModel emotionIcon;
  final String? otherSymptom;
  final String? otherActivity;
  final List<SymptomModel> symptoms;
  final List<ActivityModel> activities;
  final List<ImagesModel> images;

  InputEmotionModel({
    required this.id,
    required this.date,
    required this.emotionScore,
    required this.emotionId,
    required this.emotionText,
    required this.note,
    required this.timeFrameId,
    required this.timeFrameText,
    required this.colorCode,
    required this.backgroundColorCode,
    required this.emotionIcon,
    required this.otherSymptom,
    required this.otherActivity,
    required this.symptoms,
    required this.activities,
    required this.images,
  });
  @override
  factory InputEmotionModel.fromJson(Map<String, dynamic> json) {
    return InputEmotionModel(
        id: json['id'],
        date: json['date'],
        emotionScore: json['emotionScore'],
        emotionId: json['emotionId'],
        emotionText: json['emotionText'],
        note: json['note'],
        timeFrameId: json['timeFrameId'],
        timeFrameText: json['timeFrameText'],
        colorCode: json['colorCode'],
        backgroundColorCode: json['backgroundColorCode'],
        emotionIcon: ImagesModel.fromJson(json['emotionIcon']),
        otherSymptom: json['otherSymptom'],
        otherActivity: json['otherActivity'],
        symptoms: SymptomModel.toList(json['symptoms']),
        activities: ActivityModel.toList(json['activities']),
        images: ImagesModel.toList(json['images']));
  }

  static List<InputEmotionModel> toList(List<dynamic> items) {
    return items.map((item) => InputEmotionModel.fromJson(item)).toList();
  }
}
