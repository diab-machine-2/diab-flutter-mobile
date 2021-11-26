import 'package:meta/meta.dart';
@immutable
class TrendItemWieightModel {
  final double? value;
  final int? date;

  const TrendItemWieightModel({
    required this.value,
    required this.date,
  });
  @override
  factory TrendItemWieightModel.fromJson(Map<String, dynamic> json) {
    return TrendItemWieightModel(
      value: json['value'],
      date: json['date'],
    );
  }

  static List<TrendItemWieightModel> toList(List<dynamic> items) {
    return items.map((item) => TrendItemWieightModel.fromJson(item)).toList();
  }
}
