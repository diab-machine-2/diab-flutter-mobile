import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:meta/meta.dart';

/// Model cho danh sách input theo ngày (cũ: dayItems, mới: groups)
@immutable
class MealDayItemModel {
  final int? date;
  final String? label;
  final String? dateStr; // ISO date string from new API "2025-03-17"
  final List<MealItemModel> mealItems;

  const MealDayItemModel({
    required this.date,
    this.label,
    this.dateStr,
    required this.mealItems,
  });

  @override
  factory MealDayItemModel.fromJson(Map<String, dynamic> json) {
    // Support both old format (dayItems) and new format (groups)
    if (json['mealItems'] != null) {
      // Old format: dayItems[].mealItems[]
      return MealDayItemModel(
        date: json['date'],
        mealItems: MealItemModel.toList(json['mealItems']),
      );
    } else if (json['items'] != null) {
      // New format: groups[].items[] - each item is a nutrition input
      return MealDayItemModel(
        date: json['date'] is int
            ? json['date']
            : _parseDateToTimestamp(json['date']),
        label: json['label'],
        dateStr: json['date'] is String ? json['date'] : null,
        mealItems: _groupItemsByTimeFrame(json['items'] as List),
      );
    }
    return MealDayItemModel(date: json['date'], mealItems: []);
  }

  /// Parse ISO date string "2025-03-17" to unix timestamp
  static int? _parseDateToTimestamp(dynamic date) {
    if (date is int) return date;
    if (date is String) {
      try {
        return DateTime.parse(date).millisecondsSinceEpoch ~/ 1000;
      } catch (_) {}
    }
    return null;
  }

  /// Group flat list of nutrition input items into MealItemModels by timeFrame
  static List<MealItemModel> _groupItemsByTimeFrame(List<dynamic> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final timeFrameName = map['timeFrameName'] as String? ?? 'Khác';
      grouped.putIfAbsent(timeFrameName, () => []);
      grouped[timeFrameName]!.add(map);
    }

    return grouped.entries.map((entry) {
      double totalCalo = 0;
      final inputs = entry.value.map((item) {
        final calories = (item['calories'] as num?)?.toDouble() ?? 0;
        totalCalo += calories;
        return FoodInputModel.fromNutritionJson(item);
      }).toList();

      return MealItemModel(
        text: entry.key,
        caloValue: totalCalo,
        inputs: inputs,
      );
    }).toList();
  }

  static List<MealDayItemModel> toList(List<dynamic> items) {
    return items.map((item) => MealDayItemModel.fromJson(item)).toList();
  }
}

/// Model cho 1 lần nhập dinh dưỡng (1 bữa ăn)
class FoodInputModel {
  final String? id;
  final double? calorie;
  final double? glucose;
  final String? mealId;
  final String? mealText;
  final ImagesModel? mealIcon;
  final int? date;
  final List<ImagesModel> images;
  final List<FoodModel> foods;
  final String? note;

  // New fields from Nutrition API
  final int? totalMealScore;
  final String? scoreRange;
  final double? totalCalories;
  final int? carbPercent;
  final int? proteinPercent;
  final int? fatPercent;
  final int? vegetablePercent;
  final int? fruitPercent;
  final String? aiAdvice;
  final String? imageUrl;
  final bool? isFromAI;
  final bool? isBalanced;
  final String? timeFrameId;
  final String? timeFrameName;
  final String? createDatetime;

  FoodInputModel({
    required this.id,
    required this.calorie,
    this.glucose,
    required this.mealId,
    required this.mealText,
    required this.mealIcon,
    required this.date,
    required this.images,
    required this.foods,
    required this.note,
    this.totalMealScore,
    this.scoreRange,
    this.totalCalories,
    this.carbPercent,
    this.proteinPercent,
    this.fatPercent,
    this.vegetablePercent,
    this.fruitPercent,
    this.aiAdvice,
    this.imageUrl,
    this.isFromAI,
    this.isBalanced,
    this.timeFrameId,
    this.timeFrameName,
    this.createDatetime,
  });

  /// Parse from old /App/Diet/Input/{id} format
  @override
  factory FoodInputModel.fromJson(Map<String, dynamic> json) {
    return FoodInputModel(
      id: json['id'],
      calorie: json['calorie']?.toDouble(),
      glucose: json['glucose']?.toDouble(),
      mealId: json['mealId'] ?? json['timeFrameId'],
      mealText: json['mealText'] ?? json['timeFrameName'],
      mealIcon: json['mealIcon'] == null
          ? null
          : ImagesModel.fromJson(json['mealIcon']),
      date: json['date'] is int
          ? json['date']
          : _parseDateField(json['date'] ?? json['createDatetime']),
      images: json['images'] == null ? [] : ImagesModel.toList(json['images']),
      foods: json['foods'] != null
          ? FoodModel.toList(json['foods'])
          : (json['items'] != null
              ? _parseFoodItems(json['items'] as List)
              : []),
      note: json['note'],
      // New fields
      totalMealScore: json['totalMealScore'],
      scoreRange: json['scoreRange'],
      totalCalories: json['totalCalories']?.toDouble(),
      carbPercent: json['carbPercent'],
      proteinPercent: json['proteinPercent'],
      fatPercent: json['fatPercent'],
      vegetablePercent: json['vegetablePercent'],
      fruitPercent: json['fruitPercent'],
      aiAdvice: json['aiAdvice'],
      imageUrl: json['imageUrl'],
      isFromAI: json['isFromAI'],
      isBalanced: json['isBalanced'],
      timeFrameId: json['timeFrameId'],
      timeFrameName: json['timeFrameName'],
      createDatetime: json['createDatetime'],
    );
  }

  /// Parse from new /App/Nutrition/Input list item (group items)
  factory FoodInputModel.fromNutritionJson(Map<String, dynamic> json) {
    return FoodInputModel(
      id: json['id'],
      calorie: (json['calories'] as num?)?.toDouble(),
      glucose: null,
      mealId: json['timeFrameId'],
      mealText: json['timeFrameName'],
      mealIcon: null,
      date: _parseDateField(json['createDatetime']),
      images: [],
      foods: [],
      note: null,
      totalMealScore: json['score'],
      scoreRange: json['scoreRange'],
      totalCalories: (json['calories'] as num?)?.toDouble(),
      isBalanced: json['isBalanced'],
      timeFrameId: json['timeFrameId'],
      timeFrameName: json['timeFrameName'],
      createDatetime: json['createDatetime'],
    );
  }

  static int? _parseDateField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch ~/ 1000;
      } catch (_) {}
    }
    return null;
  }

  /// Parse new items format (items[].foodId, items[].name, items[].portion, etc.)
  static List<FoodModel> _parseFoodItems(List<dynamic> items) {
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return FoodModel(
        id: map['foodId'] ?? map['id'],
        name: map['name'],
        portion: (map['portion'] as num?)?.toDouble() ?? 1,
        unit: map['unitName'] ?? map['unit'],
        calorie: (map['calories'] as num?)?.toDouble() ??
            (map['calorie'] as num?)?.toDouble(),
        glucose: (map['glucose'] as num?)?.toDouble(),
        lipid: (map['lipid'] as num?)?.toDouble(),
        protein: (map['protein'] as num?)?.toDouble(),
        fibre: (map['fibre'] as num?)?.toDouble(),
        image:
            map['image'] != null ? ImagesModel.fromJson(map['image']) : null,
      );
    }).toList();
  }

  static List<FoodInputModel> toList(List<dynamic> items) {
    return items.map((item) => FoodInputModel.fromJson(item)).toList();
  }
}

class MealItemModel {
  final String? text;
  final double? caloValue;
  final List<FoodInputModel> inputs;

  MealItemModel(
      {required this.text, required this.caloValue, required this.inputs});

  @override
  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
        text: json['text'],
        caloValue: json['caloValue']?.toDouble(),
        inputs: FoodInputModel.toList(json['inputs']));
  }

  static List<MealItemModel> toList(List<dynamic> items) {
    return items.map((item) => MealItemModel.fromJson(item)).toList();
  }
}
