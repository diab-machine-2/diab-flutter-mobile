import 'package:meta/meta.dart';
@immutable
class ExercriseTrendSummaryModel {
  final double? total;
  final double? target;
  final String? targetTitle;
  final String? targetUnit;
  final SummaryItemModel summaryItems;

  const ExercriseTrendSummaryModel({
    required this.total,
    required this.target,
    required this.targetTitle,
    required this.targetUnit,
    required this.summaryItems,
  });
  @override
  factory ExercriseTrendSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExercriseTrendSummaryModel(
        total: json['total'],
        target: json['target'],
        targetTitle: json['targetTitle'],
        targetUnit: json['targetUnit'],
        summaryItems: SummaryItemModel.fromJson(json['summaryItems']));
  }
}

class SummaryItemModel {
  final int? total;
  final int? page;
  final int? size;
  final List<SubSummaryItemModel> items;

  SummaryItemModel(
      {required this.total,
      required this.page,
      required this.size,
      required this.items});
  @override
  factory SummaryItemModel.fromJson(Map<String, dynamic> json) {
    return SummaryItemModel(
        total: json['total'],
        page: json['page'],
        size: json['size'],
        items: json['items'] == null
            ? []
            : SubSummaryItemModel.toList(json['items']).reversed.toList());
  }
}

class SubSummaryItemModel {
  final double? burnedCalories;
  final int? date;
  final int? firstDateOfWeek;
  final int? lastDateOfWeek;
  final String? targetDescription;
  final String? targetColor;
  final TargetIconModel? targetIconUrl;

  SubSummaryItemModel({
    required this.burnedCalories,
    required this.date,
    required this.firstDateOfWeek,
    required this.lastDateOfWeek,
    required this.targetDescription,
    required this.targetColor,
    required this.targetIconUrl,
  });
  @override
  factory SubSummaryItemModel.fromJson(Map<String, dynamic> json) {
    return SubSummaryItemModel(
        burnedCalories: json['burnedCalories'],
        date: json['date'],
        firstDateOfWeek: json['firstDateOfWeek'],
        lastDateOfWeek: json['lastDateOfWeek'],
        targetDescription: json['targetDescription'],
        targetColor: json['targetColor'],
        targetIconUrl: json['targetIconUrl'] == null
            ? null
            : TargetIconModel.fromJson(json['targetIconUrl']));
  }

  static List<SubSummaryItemModel> toList(List<dynamic> items) {
    return items.map((item) => SubSummaryItemModel.fromJson(item)).toList();
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
