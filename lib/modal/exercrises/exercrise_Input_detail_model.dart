import 'package:medical/modal/exercrises/exercrises_Category.dart';
import 'package:medical/modal/exercrises/exercrises_categogy_request.dart';
import 'package:meta/meta.dart';

class InputDetailExercriseModel {
  final String id;
  final int date;
  final double burnedCalorie;
  final String unit;
  final String note;
  final String timeFrameId;
  final String timeFrame;
  final List<ExercrisesCategoryModel> exercise;
  final List<ImagesUrlModel> imageUrls;

  InputDetailExercriseModel({
    @required this.id,
    @required this.date,
    @required this.burnedCalorie,
    @required this.unit,
    @required this.note,
    @required this.timeFrameId,
    @required this.timeFrame,
    @required this.exercise,
    @required this.imageUrls,
  });
  @override
  factory InputDetailExercriseModel.fromJson(Map<String, dynamic> json) {
    return InputDetailExercriseModel(
        id: json['id'],
        date: json['date'],
        burnedCalorie: json['burnedCalorie'],
        unit: json['unit'],
        note: json['note'],
        timeFrameId: json['timeFrameId'],
        timeFrame: json['timeFrame'],
        exercise: ExercrisesCategoryModel.toList(json['exercise']),
        imageUrls: json['imageUrls'] == null
            ? []
            : ImagesUrlModel.toList(json['imageUrls']));
  }

  static List<InputDetailExercriseModel> toList(List<dynamic> items) {
    return items
        .map((item) => InputDetailExercriseModel.fromJson(item))
        .toList();
  }
}

class ListExercriseModel {
  final String id;
  final String category;
  final String name;
  final double duration;
  final double burnedCalorie;
  final String exerciseIntensityId;
  final String exerciseIntensityName;
  final String unit;
  final ImagesUrlModel imageUrl;

  ListExercriseModel({
    @required this.id,
    @required this.category,
    @required this.name,
    @required this.duration,
    @required this.burnedCalorie,
    @required this.exerciseIntensityId,
    @required this.exerciseIntensityName,
    @required this.unit,
    @required this.imageUrl,
  });
  @override
  factory ListExercriseModel.fromJson(Map<String, dynamic> json) {
    return ListExercriseModel(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      duration: json['duration'],
      burnedCalorie: json['burnedCalorie'],
      exerciseIntensityId: json['exerciseIntensityId'],
      exerciseIntensityName: json['exerciseIntensityName'],
      unit: json['unit'],
      imageUrl: ImagesUrlModel.fromJson(json['imageUrl']),
    );
  }

  static List<ListExercriseModel> toList(List<dynamic> items) {
    return items.map((item) => ListExercriseModel.fromJson(item)).toList();
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
  static List<ImagesUrlModel> toList(List<dynamic> items) {
    return items.map((item) => ImagesUrlModel.fromJson(item)).toList();
  }
}
