import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/base/images.dart';

class InputGlucoseModel {
  final String? id;
  final double? glucose;
  final String unit;
  final String? type;
  final int? createDate;
  final String? reason;
  final String? note;
  final String? timeFrame;
  final String? timeFrameId;
  final String? color;
  final String? fontColor;
  final String? backgroundColor;
  final String? borderColor;
  final List<ImagesModel> images;
  final bool byDevice;

  InputGlucoseModel({
    required this.id,
    required this.glucose,
    required this.unit,
    required this.type,
    required this.createDate,
    required this.reason,
    required this.note,
    required this.timeFrame,
    required this.timeFrameId,
    required this.color,
    required this.fontColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.images,
    required this.byDevice,
  });
  @override
  factory InputGlucoseModel.fromJson(Map<String, dynamic> json) {
    final unit = AppSettings.userInfo!.glucoseUnit == 1
        ? R.string.mg_dl.tr()
        : R.string.mmol_l.tr();
    return InputGlucoseModel(
        id: json['id'],
        glucose: AppSettings.userInfo!.glucoseUnit == 1
            ? json['glucose']
            : json['glucoseMmoll'],
        unit: unit,
        type: json['type'],
        createDate: json['createDate'],
        reason: json['reason'],
        note: json['note'],
        timeFrame: json['timeFrame'],
        timeFrameId: json['timeFrameId'],
        color: json['color'],
        fontColor: json['fontColor'],
        backgroundColor: json['backgroundColor'],
        borderColor: json['borderColor'],
        images: ImagesModel.toList(json['images']),
        byDevice: json['byDevice']);
  }

  static List<InputGlucoseModel> toList(List<dynamic> items) {
    return items.map((item) => InputGlucoseModel.fromJson(item)).toList();
  }
}
