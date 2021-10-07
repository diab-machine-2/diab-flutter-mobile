import 'package:meta/meta.dart';

class CaculateBMIModel {
  final double? bmi;
  final String? note;
  final String? colorCode;

  CaculateBMIModel({
    required this.bmi,
    required this.colorCode,
    required this.note,
  });
  @override
  factory CaculateBMIModel.fromJson(Map<String, dynamic> json) {
    return CaculateBMIModel(
      bmi: json['bmi'],
      colorCode: json['colorCode'],
      note: json['note'],
    );
  }
}
