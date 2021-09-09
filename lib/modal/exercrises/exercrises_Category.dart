import 'package:medical/modal/base/images.dart';
import 'package:meta/meta.dart';

class ExercrisesListCategoryModel {
  final List<ExercrisesCategoryModel> exerciseCategories;
  final List<ExercrisesCategoryModel> exerciseCategoryCommons;
  final List<ExercrisesCategoryModel> exerciseCategoryRegularlies;

  ExercrisesListCategoryModel(
      {@required this.exerciseCategories,
      @required this.exerciseCategoryCommons,
      @required this.exerciseCategoryRegularlies});
  @override
  factory ExercrisesListCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExercrisesListCategoryModel(
        exerciseCategories: json['exerciseCategories'] == null
            ? []
            : ExercrisesCategoryModel.toList(json['exerciseCategories']),
        exerciseCategoryCommons: json['exerciseCategoryCommons'] == null
            ? []
            : ExercrisesCategoryModel.toList(json['exerciseCategoryCommons']),
        exerciseCategoryRegularlies: json['exerciseCategoryRegularlies'] == null
            ? []
            : ExercrisesCategoryModel.toList(
                json['exerciseCategoryRegularlies']));
  }
}

class ExercrisesCategoryModel {
  final String categoryId;
  final String category;
  final String exerciseId;
  final String code;
  final double duration;
  final double burnedCalorie;
  final String exerciseIntensityId;
  final String unit;
  final String description;
  final int order;
  final ImagesModel cover;

  ExercrisesCategoryModel({
    @required this.categoryId,
    @required this.category,
    @required this.exerciseId,
    @required this.code,
    @required this.duration,
    @required this.burnedCalorie,
    @required this.exerciseIntensityId,
    @required this.unit,
    @required this.description,
    @required this.order,
    @required this.cover,
  });
  @override
  factory ExercrisesCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExercrisesCategoryModel(
        categoryId:
            json['categoryId'] == null ? json['id'] : json['categoryId'],
        category: json['category'] == null
            ? (json['name'] == null ? null : json['name'])
            : json['category'],
        exerciseId: json['exerciseId'],
        code: json['code'],
        duration: json['duration'],
        burnedCalorie: json['burnedCalorie'],
        exerciseIntensityId: json['exerciseIntensityId'],
        unit: json['unit'],
        description: json['description'],
        order: json['order'],
        cover: json['cover'] == null
            ? (json['imageUrl'] == null
                ? null
                : ImagesModel.fromJson(json['imageUrl']))
            : ImagesModel.fromJson(json['cover']));
  }
  static List<ExercrisesCategoryModel> toList(List<dynamic> items) {
    return items.map((item) => ExercrisesCategoryModel.fromJson(item)).toList();
  }
}
