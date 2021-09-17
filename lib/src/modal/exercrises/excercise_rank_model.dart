import 'package:meta/meta.dart';

class ExerciseRankModel {
  final double averagePercent;
  final double highestPercent;
  final double lowestPercent;
  final double partientPercent;
  final String description;

  ExerciseRankModel(
      {@required this.averagePercent,
      @required this.highestPercent,
      @required this.lowestPercent,
      @required this.partientPercent,
      @required this.description});
  @override
  factory ExerciseRankModel.fromJson(Map<String, dynamic> json) {
    return ExerciseRankModel(
        averagePercent: json['averagePercent'],
        highestPercent: json['highestPercent'],
        lowestPercent: json['lowestPercent'],
        partientPercent: json['partientPercent'],
        description: json['description']);
  }

  static List<ExerciseRankModel> toList(List<dynamic> items) {
    return items.map((item) => ExerciseRankModel.fromJson(item)).toList();
  }
}
