class GlucoseRangeData {
  String? glucoseBoundaryKey;
  String? glucoseBoundaryName;
  VeryLow? veryLow;
  VeryLow? low;
  VeryLow? normal;
  VeryLow? high;
  VeryLow? veryHigh;

  GlucoseRangeData(
      {this.glucoseBoundaryKey,
      this.glucoseBoundaryName,
      this.veryLow,
      this.low,
      this.normal,
      this.high,
      this.veryHigh});

  GlucoseRangeData.fromJson(Map<String, dynamic> json) {
    glucoseBoundaryKey = json['glucoseBoundaryKey'];
    glucoseBoundaryName = json['glucoseBoundaryName'];
    veryLow =
        json['veryLow'] != null ? new VeryLow.fromJson(json['veryLow']) : null;
    low = json['low'] != null ? new VeryLow.fromJson(json['low']) : null;
    normal =
        json['normal'] != null ? new VeryLow.fromJson(json['normal']) : null;
    high = json['high'] != null ? new VeryLow.fromJson(json['high']) : null;
    veryHigh = json['veryHigh'] != null
        ? new VeryLow.fromJson(json['veryHigh'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['glucoseBoundaryKey'] = this.glucoseBoundaryKey;
    data['glucoseBoundaryName'] = this.glucoseBoundaryName;
    if (this.veryLow != null) {
      data['veryLow'] = this.veryLow!.toJson();
    }
    if (this.low != null) {
      data['low'] = this.low!.toJson();
    }
    if (this.normal != null) {
      data['normal'] = this.normal!.toJson();
    }
    if (this.high != null) {
      data['high'] = this.high!.toJson();
    }
    if (this.veryHigh != null) {
      data['veryHigh'] = this.veryHigh!.toJson();
    }
    return data;
  }
}

class VeryLow {
  int? operator;
  late int value;

  VeryLow.fromJson(Map<String, dynamic> json) {
    operator = json['operator'];
    value = int.parse(json['value']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operator'] = this.operator;
    data['value'] = this.value;
    return data;
  }
}
