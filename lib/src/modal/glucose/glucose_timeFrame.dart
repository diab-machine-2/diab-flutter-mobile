class TimeFrameModel {
  final String? id;
  final String? code;
  final String? name;

  TimeFrameModel({
    required this.id,
    required this.code,
    required this.name,
  });
  @override
  factory TimeFrameModel.fromJson(Map<String, dynamic> json) {
    return TimeFrameModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  static List<TimeFrameModel> toList(List<dynamic> items) {
    return items.map((item) => TimeFrameModel.fromJson(item)).toList();
  }
}
