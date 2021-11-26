import 'package:meta/meta.dart';
@immutable
class PatientTimeFrameModel {
  final String? timeFrameId;
  final String? timeFrameName;
  final int? time;

  PatientTimeFrameModel(
      {required this.timeFrameId,
      required this.timeFrameName,
      required this.time});

  factory PatientTimeFrameModel.fromJson(Map<String, dynamic> json) {
    return PatientTimeFrameModel(
        timeFrameId: json['timeFrameId'],
        timeFrameName: json['timeFrameName'],
        time: json['time']);
  }

  static List<PatientTimeFrameModel> toList(List<dynamic> items) {
    return items.map((item) => PatientTimeFrameModel.fromJson(item)).toList();
  }
}
