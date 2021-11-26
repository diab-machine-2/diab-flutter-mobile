import 'package:meta/meta.dart';
@immutable
class ExercriseTrendTimeModel {
  final double? total;
  final double? target;
  final String? targetTitle;
  final String? targetUnit;
  final TrendItemModel trendItems;

  const ExercriseTrendTimeModel({
    required this.total,
    required this.target,
    required this.targetTitle,
    required this.targetUnit,
    required this.trendItems,
  });
  @override
  factory ExercriseTrendTimeModel.fromJson(Map<String, dynamic> json) {
    return ExercriseTrendTimeModel(
        total: json['total'],
        target: json['target'],
        targetTitle: json['targetTitle'],
        targetUnit: json['targetUnit'],
        trendItems: TrendItemModel.fromJson(json['trendItems']));
  }
}

class TrendItemModel {
  final int? total;
  final int? page;
  final int? size;
  final List<SubTrendItemModel> items;

  TrendItemModel(
      {required this.total,
      required this.page,
      required this.size,
      required this.items});
  @override
  factory TrendItemModel.fromJson(Map<String, dynamic> json) {
    return TrendItemModel(
        total: json['total'],
        page: json['page'],
        size: json['size'],
        items: json['items'] == null
            ? []
            : SubTrendItemModel.toList(json['items']).reversed.toList());
  }
}

class SubTrendItemModel {
  final double? burnedCalories;
  final double? duration;
  final int? date;
  final int? firstDateOfWeek;
  final int? lastDateOfWeek;
  final String? targetDescription;
  final String? targetColor;
  final TargetIconModel? targetIconUrl;

  SubTrendItemModel({
    required this.burnedCalories,
    required this.duration,
    required this.date,
    required this.firstDateOfWeek,
    required this.lastDateOfWeek,
    required this.targetDescription,
    required this.targetColor,
    required this.targetIconUrl,
  });
  @override
  factory SubTrendItemModel.fromJson(Map<String, dynamic> json) {
    return SubTrendItemModel(
        burnedCalories: json['burnedCalories'],
        duration: json['duration'],
        date: json['date'],
        firstDateOfWeek: json['firstDateOfWeek'],
        lastDateOfWeek: json['lastDateOfWeek'],
        targetDescription: json['targetDescription'],
        targetColor: json['targetColor'],
        targetIconUrl: json['targetIconUrl'] == null
            ? null
            : TargetIconModel.fromJson(json['targetIconUrl']));
  }

  static List<SubTrendItemModel> toList(List<dynamic> items) {
    return items.map((item) => SubTrendItemModel.fromJson(item)).toList();
  }
}

class TargetIconModel {
  final String? id;
  final String? url;

  TargetIconModel({
    required this.id,
    required this.url,
  });
  @override
  factory TargetIconModel.fromJson(Map<String, dynamic> json) {
    return TargetIconModel(
      id: json['id'],
      url: json['url'],
    );
  }
}
