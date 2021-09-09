import 'package:meta/meta.dart';

class ExercriseWalkSummaryModel {
  final String id;
  final double targetDuration;
  final double factDuration;
  final double burnedCalories;
  final ImagesUrlModel targetIconUrl;
  final String targetDescription;

  ExercriseWalkSummaryModel({
    @required this.id,
    @required this.targetDuration,
    @required this.factDuration,
    @required this.burnedCalories,
    @required this.targetIconUrl,
    @required this.targetDescription,
  });
  @override
  factory ExercriseWalkSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExercriseWalkSummaryModel(
      id: json['id'],
      targetDuration: json['targetDuration'],
      factDuration: json['factDuration'],
      burnedCalories: json['burnedCalories'],
      targetIconUrl: json['targetIconUrl'] == null
          ? null
          : ImagesUrlModel.fromJson(json['targetIconUrl']),
      targetDescription: json['targetDescription'],
    );
  }

  static List<ExercriseWalkSummaryModel> toList(List<dynamic> items) {
    return items
        .map((item) => ExercriseWalkSummaryModel.fromJson(item))
        .toList();
  }
}

class ImagesUrlModel {
  final String id;
  final String url;

  ImagesUrlModel({@required this.id, @required this.url});
  @override
  factory ImagesUrlModel.fromJson(Map<String, dynamic> json) {
    return ImagesUrlModel(
      id: json['id'],
      url: json['url'],
    );
  }
}
