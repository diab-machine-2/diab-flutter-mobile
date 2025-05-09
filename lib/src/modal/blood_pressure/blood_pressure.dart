import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';
@immutable
class BloodPressureModel {
  final String? id;
  final double? systolic;
  final double? diastolic;
  final double? pulseRate;
  final String? pulseRateStatus;
  final String? bloodPressureType;
  final int? date;
  final String? timeFrame;
  final String? timeFrameId;
  final String? note;
  final String? reason;
  final String? color;
  final String? fontColor;
  final String? backgroundColor;
  final String? borderColor;
  final List<ImagesModel> images;

  const BloodPressureModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulseRate,
    this.pulseRateStatus,
    required this.bloodPressureType,
    required this.date,
    required this.timeFrame,
    required this.timeFrameId,
    required this.note,
    required this.reason,
    required this.color,
    required this.fontColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.images,
  });
  @override
  factory BloodPressureModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureModel(
        id: json['id'],
        systolic: json['systolic'],
        diastolic: json['diastolic'],
        pulseRate: json['pulseRate'],
        pulseRateStatus: json['pulseRateStatus'],
        bloodPressureType: json['bloodPressureType'],
        date: json['date'],
        timeFrame: json['timeFrame'],
        timeFrameId: json['timeFrameId'],
        note: json['note'],
        reason: json['reason'],
        color: json['color'],
        fontColor: json['fontColor'],
        backgroundColor: json['backgroundColor'],
        borderColor: json['borderColor'],
        images: ImagesModel.toList(json['images']));
  }

  static List<BloodPressureModel> toList(List<dynamic> items) {
    return items.map((item) => BloodPressureModel.fromJson(item)).toList();
  }
}
