import 'package:meta/meta.dart';

@immutable
class GoalInfoModel {
  final double? dailyWalkTargetDuration;
  final double? dailyTargetDuration;
  final double? weeklyTargetDuration;
  final double? dailyTargetBurnedCalorie;
  final double? dailyEnergyGoal;
  final double? goalWaist;
  final double? goalWeight;

  const GoalInfoModel(
      {required this.dailyWalkTargetDuration,
      required this.dailyTargetDuration,
      required this.weeklyTargetDuration,
      required this.dailyTargetBurnedCalorie,
      required this.dailyEnergyGoal,
      required this.goalWaist,
      required this.goalWeight});

  GoalInfoModel copyWith({
    double? dailyWalkTargetDuration,
    double? dailyTargetDuration,
    double? weeklyTargetDuration,
    double? dailyTargetBurnedCalorie,
    double? dailyEnergyGoal,
    double? goalWaist,
    double? goalWeight,
  }) {
    return GoalInfoModel(
      dailyWalkTargetDuration:
          dailyWalkTargetDuration ?? this.dailyWalkTargetDuration,
      dailyTargetDuration: dailyTargetDuration ?? this.dailyTargetDuration,
      weeklyTargetDuration: weeklyTargetDuration ?? this.weeklyTargetDuration,
      dailyTargetBurnedCalorie:
          dailyTargetBurnedCalorie ?? this.dailyTargetBurnedCalorie,
      dailyEnergyGoal: dailyEnergyGoal ?? this.dailyEnergyGoal,
      goalWaist: goalWaist ?? this.goalWaist,
      goalWeight: goalWeight ?? this.goalWeight,
    );
  }

  factory GoalInfoModel.fromJson(Map<String, dynamic> json) {
    return GoalInfoModel(
        dailyWalkTargetDuration: json['dailyWalkTargetDuration'],
        dailyTargetDuration: json['dailyTargetDuration'],
        weeklyTargetDuration: json['weeklyTargetDuration'],
        dailyTargetBurnedCalorie: json['dailyTargetBurnedCalorie'],
        dailyEnergyGoal: json['dailyEnergyGoal'],
        goalWaist: json['goalWaist'],
        goalWeight: json['goalWeight']);
  }

  static List<GoalInfoModel> toList(List<dynamic> items) {
    return items.map((item) => GoalInfoModel.fromJson(item)).toList();
  }
}
