import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/goal_info.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_smart_goal_request.dart';
import 'package:medical/src/model/response/create_smart_goal_response.dart';
import 'package:medical/src/model/response/smart_goal_detail_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';

import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';

class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository) : super(const CreateGoalInitial());

  final AppRepository repository;

  CreateGoalStatus status = CreateGoalStatus.select_type;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isRepeat = false;
  GoalRecordType goalRecordType = GoalRecordType.time;
  ScheduleType? type;
  RepeatType repeatType = RepeatType.day;
  List<DayInWeek> repeatDayList = [];
  String name = '';
  String goalTimeOrFrequency = '';

  GoalInfoModel? userInfo;

  String dailyTargetDuration = '';
  String weeklyTargetDuration = '';

  SmartGoalListReponseData? smartGoalDetail;

  bool get isValid {
    if (type == null || type == ScheduleType.custom) {
      if (name.isEmpty) {
        showError(R.string.smart_goal_name_empty.tr());
        return false;
      }
      if (isRepeat && repeatType == RepeatType.week && repeatDayList.isEmpty) {
        showError(R.string.smart_goal_repeat_day_empty.tr());
        return false;
      }
      if (goalTimeOrFrequency.isEmpty) {
        showError(
            'Chưa nhập ${goalRecordType == GoalRecordType.time ? 'thời gian thực hiện' : 'số lần thực hiện'}');
        return false;
      }
    } else if (type == ScheduleType.exercise) {
      if (userInfo?.dailyTargetDuration == null ||
          userInfo?.weeklyTargetDuration == null) {
        showError(R.string.smart_goal_exercise_time_empty.tr());
        return false;
      }
    } else {
      if (isRepeat && repeatType == RepeatType.week && repeatDayList.isEmpty) {
        showError(R.string.smart_goal_repeat_day_empty.tr());
        return false;
      }
      if (goalTimeOrFrequency.isEmpty) {
        showError(R.string.smart_goal_exercise_frequency_empty.tr());
        return false;
      }
    }
    return true;
  }

  void showError(String message) {
    emit(CreateGoalFailure(message));
    emit(const CreateGoalInitial());
  }

  int get repeatTypeIndex {
    if (repeatType == RepeatType.day) return 0;
    if (repeatType == RepeatType.week) return 1;
    return 2;
  }

  int parseString(String text) {
    try {
      final int number = double.parse(text).toInt();
      return number;
    } catch (_) {
      return 0;
    }
  }

  List<CustomWeekList?> get targetSchedulerWeeks => List.generate(
        repeatDayList.length,
        (index) => CustomWeekList(dayInWeek: repeatDayList[index].index),
      );

  CreateSmartGoalRequest? get request {
    if (type == ScheduleType.exercise) return null;
    if (type == null || type == ScheduleType.custom) {
      return CreateSmartGoalRequest(
        id: smartGoalDetail?.id,
        name: name,
        type: type?.typeIndex ?? 0,
        appointmentDate: (startDate.millisecondsSinceEpoch ~/ 1000).toInt(),
        targetSchedulerId: smartGoalDetail?.targetSchedulerId,
        executeType: goalRecordType.index,
        executeDayTimes: parseString(goalTimeOrFrequency),
        targetScheduler: CustomScheduler(
            repeatTime: 1,
            repeatType: repeatTypeIndex,
            endDate: (endDate.millisecondsSinceEpoch ~/ 1000).toInt(),
            targetSchedulerWeeks: targetSchedulerWeeks),
      );
    } else {
      return CreateSmartGoalRequest(
        id: smartGoalDetail?.id,
        name: type?.title ?? '',
        type: type?.typeIndex,
        appointmentDate: (startDate.millisecondsSinceEpoch ~/ 1000).toInt(),
        targetSchedulerId: smartGoalDetail?.targetSchedulerId,
        executeType: GoalRecordType.time.index,
        executeDayTimes: parseString(goalTimeOrFrequency),
        targetScheduler: CustomScheduler(
            repeatTime: 1,
            repeatType: repeatTypeIndex,
            endDate: (endDate.millisecondsSinceEpoch ~/ 1000).toInt(),
            targetSchedulerWeeks: targetSchedulerWeeks),
      );
    }
  }

  void setupGoal({ScheduleType? selectedType}) {
    type = selectedType;
    if (selectedType != null && selectedType != ScheduleType.custom) {
      goalRecordType = GoalRecordType.frequency;
    }
    status = CreateGoalStatus.setup;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onToggleRepeat() {
    isRepeat = !isRepeat;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeCalculateType(int newIndex) {
    goalRecordType = GoalRecordTypeExtend.getGoalRecordTypeFromIndex(newIndex);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatType(String selectedRepeatType) {
    repeatType = RepeatTypeExtend.getTypeFromString(selectedRepeatType);
    if (repeatType == RepeatType.day) {
      repeatDayList.clear();
    }
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatDay(List<String> selectedDayList) {
    repeatDayList = selectedDayList
        .map((e) => DayInWeekExtend.getDayInWeekFromString(e))
        .toList();
    repeatDayList.sort((a, b) => a.index - b.index);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  Future<void> fillData(SmartGoalListReponseData datai) async {
    await getSmartGoalDetail(id: datai.id ?? '');
    if (smartGoalDetail == null) return;
    name = smartGoalDetail?.name ?? '';
    startDate = smartGoalDetail?.startDate ?? DateTime.now();
    endDate = startDate;
    if (smartGoalDetail?.targetScheduler != null) {
      isRepeat = true;
      repeatType = RepeatTypeExtend.getTypeFromNumber(
          smartGoalDetail?.targetScheduler?.repeatType);
      repeatDayList = smartGoalDetail?.repeatDayList ?? [];
    }
    goalRecordType = smartGoalDetail!.goalRecordType;
    goalTimeOrFrequency = '${smartGoalDetail?.executeDayTimes ?? 0}';
  }

  Future<void> onTapNext() async {
    if (status == CreateGoalStatus.setup) {
      if (!isValid) return;
      status = CreateGoalStatus.complete;
      emit(const CreateGoalSuccess());
    } else if (status == CreateGoalStatus.complete) {
      if (type == ScheduleType.exercise) {
        await updateUserTarget();
      } else {
        await createSmartGoal();
      }

      emit(const CreateGoalCompleted());
    }
    emit(const CreateGoalInitial());
  }

  Future<void> createSmartGoal() async {
    emit(const CreateGoalLoading());
    final ApiResult<CreateSmartGoalResponse> apiResult =
        await repository.createSmartGoal(request ?? CreateSmartGoalRequest());
    apiResult.when(success: (CreateSmartGoalResponse response) {
      emit(const CreateGoalSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CreateGoalFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const CreateGoalInitial());
  }

  Future<void> getUserTarget() async {
    await Future.delayed(Duration.zero);
    emit(const CreateGoalLoading());
    try {
      userInfo = await UserClient().fetchGoalInfo();
      dailyTargetDuration = '${userInfo?.dailyTargetDuration ?? 0}';
      weeklyTargetDuration = '${userInfo?.weeklyTargetDuration ?? 0}';
    } catch (error) {
      emit(CreateGoalFailure(error.toString()));
    }
    emit(const CreateGoalInitial());
  }

  Future<void> updateUserTarget() async {
    if (userInfo == null) return;
    await Future.delayed(Duration.zero);
    emit(const CreateGoalLoading());
    final GoalInfoModel request = userInfo!.copyWith(
      dailyTargetDuration: parseString(this.dailyTargetDuration).toDouble(),
      weeklyTargetDuration: parseString(this.weeklyTargetDuration).toDouble(),
    );
    try {
      await UserClient().updateGoalInfo(request);
    } catch (error) {
      emit(CreateGoalFailure(error.toString()));
    }
    emit(const CreateGoalInitial());
  }

  Future<void> getSmartGoalDetail({required String id}) async {
    await Future.delayed(Duration.zero);
    emit(const CreateGoalLoading());
    final ApiResult<SmartGoalDetailResponse> apiResult =
        await repository.getSmartGoalDetail(id: id);
    apiResult.when(success: (SmartGoalDetailResponse response) {
      smartGoalDetail = response.data;
      emit(const CreateGoalSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CreateGoalFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const CreateGoalInitial());
  }
}
