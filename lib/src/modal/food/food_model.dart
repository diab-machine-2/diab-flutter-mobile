import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

@immutable
class FoodModel {
  final String? id;
  final String? code;
  final String? name;
  final double? portion;
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
  final double? quantity;
  final String? mealId;
  final int? timeCode;

  const FoodModel({
    required this.id,
    this.code,
    this.name,
    this.portion,
    this.unit,
    this.calorie,
    this.glucose,
    this.lipid,
    this.protein,
    this.fibre,
    this.image,
    this.liked,
    this.text,
    this.description,
    this.foodCategoryId,
    this.quantity,
    this.mealId,
    this.timeCode,
  });

  @override
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      portion: json['portion'] == null ? 1 : json['portion'].toDouble() ?? 1,
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
      image: json['image'] == null ? null : ImagesModel.fromJson(json['image']),
      liked: json['liked'],
      text: json['text'],
      description: json['description'],
      foodCategoryId: json['foodCategoryId'],
      quantity: json['inputPortion'] ?? 1,
      mealId: json['mealId'],
    );
  }

  double? get totalKcal {
    if (calorie == null || portion == null) return null;
    return calorie! * portion!;
  }

  static List<FoodModel> toList(List<dynamic> items) {
    return items.map((item) => FoodModel.fromJson(item)).toList();
  }

  FoodModel copyWith({
    String? id,
    String? code,
    String? name,
    double? portion,
    String? unit,
    double? calorie,
    double? glucose,
    double? lipid,
    double? protein,
    double? fibre,
    ImagesModel? image,
    bool? liked,
    String? text,
    String? description,
    String? foodCategoryId,
    double? quantity,
    String? mealId,
    int? timeCode,
  }) {
    return FoodModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      portion: portion ?? this.portion,
      unit: unit ?? this.unit,
      calorie: calorie ?? this.calorie,
      glucose: glucose ?? this.glucose,
      lipid: lipid ?? this.lipid,
      protein: protein ?? this.protein,
      fibre: fibre ?? this.fibre,
      image: image ?? this.image,
      liked: liked ?? this.liked,
      text: text ?? this.text,
      description: description ?? this.description,
      foodCategoryId: foodCategoryId ?? this.foodCategoryId,
      quantity: quantity ?? this.quantity,
      mealId: mealId ?? this.mealId,
      timeCode: timeCode ?? this.timeCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
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
        'quantity': quantity,
      };
}
