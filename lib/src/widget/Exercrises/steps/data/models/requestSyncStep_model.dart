import 'package:meta/meta.dart';

@immutable
class RequestSyncStepModel {
  late int dateFrom;
  late int dateTo;
  late int value;
  late String platform;
  late int totalMinute;
  late double burnCalories;

  RequestSyncStepModel({
    required this.dateFrom,
    required this.dateTo,
    required this.value,
    required this.platform,
    required this.totalMinute,
    required this.burnCalories,
  });

  RequestSyncStepModel.fromJson(Map<String, dynamic> json) {
    dateFrom = json["dateFrom"];
    dateTo = json["dateTo"];
    value = json["value"] ?? 0;
    platform = json["platform"];
    totalMinute = json["totalMinute"];
    burnCalories = json["burnCalories"] ?? 0;
  }

  RequestSyncStepModel copyWith({
    int? value,
    int? totalMinute,
    double? burnCalories,
  }) {
    return RequestSyncStepModel(
      value: value ?? this.value,
      totalMinute: totalMinute ?? this.totalMinute,
      dateFrom: dateFrom,
      dateTo: dateTo,
      platform: platform,
      burnCalories: burnCalories ?? this.burnCalories,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["dateFrom"] = dateFrom;
    _data["dateTo"] = dateTo;
    _data["value"] = value;
    _data["platform"] = platform;
    _data["totalMinute"] = totalMinute;
    _data["burnCalories"] = burnCalories;
    return _data;
  }
}
