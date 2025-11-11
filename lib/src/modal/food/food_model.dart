import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

@immutable
class FoodModel {
  final String? id;
  String? code;
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
  String? foodMenuCode;
  String? imageUrl;

  FoodModel({
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
    this.foodMenuCode,
    this.imageUrl,
  });

  @override
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      portion: json['portion'] == null ? 1 : json['portion'].toDouble() ?? 1,
      unit: json['unit'] != null && json['unit'].toString().isNotEmpty
          ? (() {
              final unitStr = json['unit'].toString();
              return unitStr[0].toUpperCase() +
                  (unitStr.length > 1 ? unitStr.substring(1) : '');
            })()
          : json['unit'],
      calorie: json['calorie'] == null
          ? (json['caloValue'] == null
              ? (json['caloriesPerUnit'] == null
                  ? null
                  : json['caloriesPerUnit'].toDouble())
              : json['caloValue'].toDouble())
          : json['calorie'].toDouble(),
      glucose: json['glucose']?.toDouble(),
      lipid: json['lipid']?.toDouble(),
      protein: json['protein']?.toDouble(),
      fibre: json['fibre']?.toDouble(),
      image: json['image'] == null ? null : ImagesModel.fromJson(json['image']),
      liked: json['liked'],
      text: json['text'],
      description: json['description'],
      foodCategoryId: json['foodCategoryId'],
      quantity:
          json['inputPortion'] == null ? 1 : json['inputPortion'].toDouble(),
      mealId: json['mealId'],
      imageUrl: json['imageUrl'],
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
    String? foodMenuCode,
    String? imageUrl,
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
      foodMenuCode: foodMenuCode ?? this.foodMenuCode,
      imageUrl: imageUrl ?? this.imageUrl,
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
