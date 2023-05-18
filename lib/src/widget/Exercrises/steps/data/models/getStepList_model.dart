class GetStepListModel {
  late Meta meta;
  late StepListModel data;

  GetStepListModel.fromJson(Map<String, dynamic> json) {
    meta = Meta.fromJson(json["meta"]);
    data = StepListModel.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["meta"] = meta.toJson();
    _data["data"] = data.toJson();
    return _data;
  }
}

class StepListModel {
  late List<StepItemModel> items;
  int? totalStep;

  StepListModel.fromJson(Map<String, dynamic> json) {
    items = json["items"] == null
        ? []
        : (json["items"] as List)
            .map((e) => StepItemModel.fromJson(e))
            .toList();
    totalStep = json["totalStep"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if (items.isNotEmpty) {
      _data["items"] = items.map((e) => e.toJson()).toList();
    }
    _data["totalStep"] = totalStep;
    return _data;
  }
}

class StepItemModel {
  int? dateFrom;
  int? dateTo;
  num? value;
  String? platform;
  num? totalMinute;

  StepItemModel(
      {this.dateFrom,
      this.dateTo,
      this.value,
      this.platform,
      this.totalMinute});

  StepItemModel.fromJson(Map<String, dynamic> json) {
    dateFrom = json["dateFrom"];
    dateTo = json["dateTo"];
    value = json["value"];
    platform = json["platform"];
    totalMinute = json["totalMinute"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["dateFrom"] = dateFrom;
    _data["dateTo"] = dateTo;
    _data["value"] = value;
    _data["platform"] = platform;
    _data["totalMinute"] = totalMinute;
    return _data;
  }
}

class Meta {
  bool? success;

  Meta({this.success});

  Meta.fromJson(Map<String, dynamic> json) {
    success = json["success"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["success"] = success;
    return _data;
  }
}
