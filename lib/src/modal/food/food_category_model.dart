import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

class FoodCategoryModel {
  final String? id;
  final String? name;
  final List<FoodSubCategoryModel> subCategories;

  FoodCategoryModel({
    required this.id,
    required this.name,
    required this.subCategories,
  });
  @override
  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) {
    return FoodCategoryModel(
        id: json['id'],
        name: json['name'],
        subCategories: FoodSubCategoryModel.toList(json['subCategories']));
  }

  static List<FoodCategoryModel> toList(List<dynamic> items) {
    return items.map((item) => FoodCategoryModel.fromJson(item)).toList();
  }
}

class FoodSubCategoryModel {
  final String? id;
  final String? name;
  final ImagesModel image;

  FoodSubCategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });
  @override
  factory FoodSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return FoodSubCategoryModel(
        id: json['id'],
        name: json['name'],
        image: ImagesModel.fromJson(json['image']));
  }

  static List<FoodSubCategoryModel> toList(List<dynamic> items) {
    return items.map((item) => FoodSubCategoryModel.fromJson(item)).toList();
  }
}
