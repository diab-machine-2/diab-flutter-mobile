import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/create_smart_goal_request.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/utils/utils.dart';

import '../../activity_tab/models/schedule_type.dart';
import 'day_in_week.dart';
import 'goal_record_type.dart';
import 'repeat_type.dart';

class CreateSmartGoalData {
  CreateSmartGoalData(
      {DateTime? endDate,
      this.isRepeat = false,
      this.goalRecordType = GoalRecordType.time,
      this.type,
      this.repeatType = RepeatType.day,
      this.repeatDayList = const [],
      this.name = '',
      this.goalTimeOrFrequency = '',
      this.dailyTargetDuration = ''}) {
    this.endDate = endDate ?? DateTime.now();
  }

  DateTime endDate = DateTime.now();

  bool isRepeat = false;

  GoalRecordType goalRecordType = GoalRecordType.time;

  ScheduleType? type;

  //Because there are two smartGoal have the same type ("Create a new habit" and "Do a favorite thing")
  //The subType field used to distinguish these case
  //subType == 0 -> Create a new habit
  //subType == 1 -> Do a favorite thing
  int? subType;

  ScheduleType? cachedType;

  int? cachedSubType;

  RepeatType? repeatType;

  List<DayInWeek> repeatDayList = [];

  String name = '';

  String goalTimeOrFrequency = '';

  String dailyTargetDuration = '';

  void resetData() {
    endDate = DateTime.now();
    isRepeat = false;
    goalRecordType = GoalRecordType.time;
    type = null;
    cachedType = null;
    cachedSubType = null;
    repeatType = null;
    repeatDayList = [];
    name = '';
    goalTimeOrFrequency = '';
  }

  void fillData(ScheduleType newType, SmartGoalList? smartGoalData) {
    if (newType == null) return;
    switch (newType) {
      case ScheduleType.blood_pressure:
        if (smartGoalData == null) {
          goalTimeOrFrequency = '1';
          isRepeat = true;
          repeatType = RepeatType.week;
          repeatDayList = [DayInWeek.tue, DayInWeek.fri];
          endDate = DateTime.now().add(const Duration(days: 90));
          return;
        }
        if (smartGoalData != null) {
          fillDataFromSmartGoal(smartGoalData);
          return;
        }
        break;
      case ScheduleType.weight:
        if (smartGoalData == null) {
          goalTimeOrFrequency = '1';
          isRepeat = true;
          repeatType = RepeatType.week;
          repeatDayList = [DayInWeek.sun];
          endDate = DateTime.now().add(const Duration(days: 90));
          return;
        }
        if (smartGoalData != null) {
          fillDataFromSmartGoal(smartGoalData);
          return;
        }
        break;
      case ScheduleType.emotion:
        if (smartGoalData == null) {
          goalTimeOrFrequency = '3';
          isRepeat = true;
          repeatType = RepeatType.week;
          repeatDayList = [DayInWeek.tue, DayInWeek.sat];
          endDate = DateTime.now().add(const Duration(days: 90));
          return;
        }
        if (smartGoalData != null) {
          fillDataFromSmartGoal(smartGoalData);
          return;
        }
        break;
      case ScheduleType.exercise:
        if (smartGoalData == null) {
          dailyTargetDuration = '30';
          return;
        }
        if (smartGoalData != null) {
          dailyTargetDuration = '${smartGoalData.executeDayTimes}';
        }
        break;

      default:
    }
  }

  void fillDataFromSmartGoal(SmartGoalList smartGoalData) {
    goalTimeOrFrequency = '${smartGoalData.executeDayTimes ?? 0}';
    if (smartGoalData.targetScheduler != null) {
      isRepeat = true;
      repeatType = RepeatTypeExtend.getTypeFromNumber(
          smartGoalData.targetScheduler?.repeatType);
      repeatDayList = smartGoalData.targetScheduler?.repeatDayList ?? [];
      endDate = DateTime.fromMillisecondsSinceEpoch(
          (smartGoalData.targetScheduler?.endDate ?? 0) * 1000);
    }
  }

  int get dailyTargetDurationNumber =>
      Utils.parseStringToInt(dailyTargetDuration);

  CreateSmartGoalData get copy => CreateSmartGoalData(
      endDate: this.endDate,
      isRepeat: this.isRepeat,
      goalRecordType: this.goalRecordType,
      type: this.type,
      repeatType: this.repeatType,
      repeatDayList: this.repeatDayList,
      name: this.name,
      goalTimeOrFrequency: this.goalTimeOrFrequency,
      dailyTargetDuration: this.dailyTargetDuration);

  String get checkValid {
    if (type == null || type == ScheduleType.custom) {
      if (name.isEmpty) {
        return R.string.smart_goal_name_empty.tr(args: [
          if (subType == 0) 'Tên mục tiêu của bạn' else 'Tên việc làm yêu thích'
        ]);
      }
      if (isRepeat && repeatType == null) {
        return 'Mức độ thường xuyên là bắt buộc';
      }
      if (isRepeat && repeatType == RepeatType.week && repeatDayList.isEmpty) {
        return R.string.smart_goal_repeat_day_empty.tr();
      }
      if (goalTimeOrFrequency.isEmpty ||
          Utils.parseStringToInt(goalTimeOrFrequency) == 0) {
        return 'Chưa nhập ${goalRecordType == GoalRecordType.time ? 'thời gian thực hiện' : 'số lần thực hiện'}';
      }
    } else if (type == ScheduleType.exercise) {
      if (dailyTargetDuration.isEmpty) {
        return R.string.smart_goal_exercise_time_empty.tr();
      }
    } else {
      if (isRepeat && repeatType == null) {
        return 'Mức độ thường xuyên là bắt buộc';
      }
      if (isRepeat && repeatType == RepeatType.week && repeatDayList.isEmpty) {
        return R.string.smart_goal_repeat_day_empty.tr();
      }
      if (goalTimeOrFrequency.isEmpty ||
          Utils.parseStringToInt(goalTimeOrFrequency) == 0) {
        return R.string.smart_goal_exercise_frequency_empty.tr();
      }
    }
    return '';
  }

  List<CustomWeekList?> get targetSchedulerWeeks => List.generate(
        repeatDayList.length,
        (index) => CustomWeekList(dayInWeek: repeatDayList[index].index),
      );

  int get repeatTypeIndex {
    if (repeatType == RepeatType.day) return 0;
    if (repeatType == RepeatType.week) return 1;
    return 2;
  }

  CustomScheduler? get schedule => isRepeat
      ? CustomScheduler(
          repeatTime: 1,
          repeatType: repeatTypeIndex,
          endDate: (endDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          targetSchedulerWeeks: targetSchedulerWeeks)
      : null;

  CreateSmartGoalRequest? get request {
    if (type == ScheduleType.exercise) {
      return CreateSmartGoalRequest(
        name: type?.title ?? '',
        type: type?.typeIndex,
        executeType: GoalRecordType.time.index,
        executeDayTimes: Utils.parseStringToInt(dailyTargetDuration),
        targetScheduler: schedule,
      );
    }
    if (type == null || type == ScheduleType.custom) {
      return CreateSmartGoalRequest(
        name: name,
        type: type?.typeIndex ?? 0,
        executeType: goalRecordType.index,
        executeDayTimes: Utils.parseStringToInt(goalTimeOrFrequency),
        targetScheduler: schedule,
      );
    } else {
      return CreateSmartGoalRequest(
        name: type?.title ?? '',
        type: type?.typeIndex,
        executeType: GoalRecordType.frequency.index,
        executeDayTimes: Utils.parseStringToInt(goalTimeOrFrequency),
        targetScheduler: schedule,
      );
    }
  }
}
