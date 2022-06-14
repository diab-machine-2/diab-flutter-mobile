import 'package:medical/src/model/response/smart_goal_statistic_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';

class StatisticData {
  SmartGoalStatisticResponseData? targets;
  List<WeekStatesResponseData?>? lessons;
  List<WeekStatesResponseData?>? exerciseMovements;

  StatisticData({
    this.targets,
    this.lessons,
    this.exerciseMovements,
  });

  StatisticData.fromJson(Map<String, dynamic> json) {
    targets = (json['targets'] != null) ? SmartGoalStatisticResponseData.fromJson(json['targets']) : null;
    if (json['lessons'] != null) {
      final v = json['lessons'];
      final arr0 = <WeekStatesResponseData>[];
      v.forEach((v) {
        arr0.add(WeekStatesResponseData.fromJson(v));
      });
      lessons = arr0;
    }
    if (json['exerciseMovements'] != null) {
      final v = json['exerciseMovements'];
      final arr0 = <WeekStatesResponseData>[];
      v.forEach((v) {
        arr0.add(WeekStatesResponseData.fromJson(v));
      });
      exerciseMovements = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (targets != null) {
      data['targets'] = targets!.toJson();
    }
    if (lessons != null) {
      final v = lessons;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['lessons'] = arr0;
    }
    if (exerciseMovements != null) {
      final v = exerciseMovements;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['exerciseMovements'] = arr0;
    }
    return data;
  }
}