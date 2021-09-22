import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

class FoodModel {
  final String? id;
  final String? name;
  final double portion;
  final String? unit;
  final double? calorie;
  final double? glucose;
  final double? lipid;
  final double? protein;
  final double? fibre;
  final ImagesModel? image;
  final bool? liked;
  final String? text;
  final String? description;
  final String? foodCategoryId;
  final double quantity;

  FoodModel(
      {required this.id,
      required this.name,
      required this.portion,
      required this.unit,
      required this.calorie,
      required this.glucose,
      required this.lipid,
      required this.protein,
      required this.fibre,
      required this.image,
      required this.liked,
      required this.text,
      required this.description,
      required this.foodCategoryId,
      required this.quantity});

  @override
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
        id: json['id'],
        name: json['name'],
        portion: json['portion'] == null ? 0 : json['portion'].toDouble() ?? 0,
        unit: json['unit'],
        calorie: json['calorie'] == null
            ? (json['caloValue'] == null
                ? json['caloriesPerUnit']
                : json['caloValue'])
            : json['calorie'],
        glucose: json['glucose'],
        lipid: json['lipid'],
        protein: json['protein'],
        fibre: json['fibre'],
        image:
            json['image'] == null ? null : ImagesModel.fromJson(json['image']),
        liked: json['liked'],
        text: json['text'],
        description: json['description'],
        foodCategoryId: json['foodCategoryId'],
        quantity: json['inputPortion'] ?? 1);
  }

  static List<FoodModel> toList(List<dynamic> items) {
    return items.map((item) => FoodModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'portion': portion,
        'unit': unit,
        'calorie': calorie,
        'glucose': glucose,
        'lipid': lipid,
        'protein': protein,
        'fibre': fibre,
        'image': image,
        'liked': liked,
        'text': text,
        'description': description,
        'foodCategoryId': foodCategoryId,
        'quantity': quantity
      };
}
