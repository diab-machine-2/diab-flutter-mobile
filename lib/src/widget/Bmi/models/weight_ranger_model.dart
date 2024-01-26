class WeightRangeModel {
  double? weight;
  String? colorCode;
  String? backgroundColorCode;
  String? name;

  WeightRangeModel.fromJson(Map<String, dynamic> json) {
    weight = json['weight'];
    colorCode = json['colorCode'];
    name = json['name'];
    backgroundColorCode = json['backgroundColorCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['weight'] = this.weight;
    data['colorCode'] = this.colorCode;
    data['name'] = this.name;
    data['backgroundColorCode'] = this.backgroundColorCode;
    return data;
  }
}
