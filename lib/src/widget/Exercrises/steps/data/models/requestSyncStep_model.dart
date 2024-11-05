import 'package:meta/meta.dart';

@immutable
class RequestSyncStepModel {
  late int dateFrom;
  late int dateTo;
  late int value;
  late String platform;
  late int totalMinute;
  late double caloriesBurned;

  RequestSyncStepModel({
    required this.dateFrom,
    required this.dateTo,
    required this.value,
    required this.platform,
    required this.totalMinute,
    required this.caloriesBurned,
  });

  RequestSyncStepModel.fromJson(Map<String, dynamic> json) {
    dateFrom = json["dateFrom"];
    dateTo = json["dateTo"];
    value = json["value"] ?? 0;
    platform = json["platform"];
    totalMinute = json["totalMinute"];
    caloriesBurned = json["caloriesBurned"] ?? 0;
  }

  RequestSyncStepModel copyWith({
    int? value,
    int? totalMinute,
    double? caloriesBurned,
  }) {
    return RequestSyncStepModel(
      value: value ?? this.value,
      totalMinute: totalMinute ?? this.totalMinute,
      dateFrom: dateFrom,
      dateTo: dateTo,
      platform: platform,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["dateFrom"] = dateFrom;
    _data["dateTo"] = dateTo;
    _data["value"] = value;
    _data["platform"] = platform;
    _data["totalMinute"] = totalMinute;
    _data["caloriesBurned"] = caloriesBurned;
    return _data;
  }
}
