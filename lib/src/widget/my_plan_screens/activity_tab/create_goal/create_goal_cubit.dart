import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_smart_goal_request.dart';
import 'package:medical/src/model/response/create_smart_goal_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';

import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/create_smart_goal_data.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';

class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository) : super(const CreateGoalInitial());

  final AppRepository repository;

  CreateSmartGoalData dataModel = CreateSmartGoalData();

  CreateGoalStatus status = CreateGoalStatus.select_type;

  bool get isValid {
    final String errorMessage = dataModel.checkValid;
    if (errorMessage.isEmpty) return true;
    showError(errorMessage);
    return false;
  }

  void showError(String message) {
    emit(CreateGoalFailure(message));
    emit(const CreateGoalInitial());
  }

  bool get showDetail => !(status != CreateGoalStatus.setup ||
      dataModel.type == ScheduleType.custom);

  Future<void> setupGoal({ScheduleType? selectedType}) async {
    dataModel.type = selectedType;
    if (selectedType != null && selectedType != ScheduleType.custom) {
      dataModel.goalRecordType = GoalRecordType.frequency;
    }
    status = CreateGoalStatus.setup;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onToggleRepeat() {
    dataModel.isRepeat = !dataModel.isRepeat;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatType(String selectedRepeatType) {
    dataModel.repeatType =
        RepeatTypeExtend.getTypeFromString(selectedRepeatType);
    if (dataModel.repeatType == RepeatType.day) {
      dataModel.repeatDayList.clear();
    }
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatDay(List<String> selectedDayList) {
    dataModel.repeatDayList = selectedDayList
        .map((e) => DayInWeekExtend.getDayInWeekFromString(e))
        .toList();
    dataModel.repeatDayList.sort((a, b) => a.index - b.index);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onSelectStatus(CreateGoalStatus newStatus) {
    status = newStatus;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  Future<void> onTapNext() async {
    if (status == null) return;
    if (status == CreateGoalStatus.setup) {
      if (!isValid) return;
      status = CreateGoalStatus.complete;
      emit(const CreateGoalSuccess());
    } else if (status == CreateGoalStatus.complete) {
      await createSmartGoal();
      emit(const CreateGoalCompleted());
    }
    emit(const CreateGoalInitial());
  }

  Future<void> createSmartGoal() async {
    emit(const CreateGoalLoading());
    late final ApiResult<CreateSmartGoalResponse> apiResult;
    apiResult = await repository
        .createSmartGoal(dataModel.request ?? CreateSmartGoalRequest());
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
      dataModel.userInfo = await UserClient().fetchGoalInfo();
      dataModel.dailyTargetDuration =
          '${dataModel.userInfo?.dailyTargetDuration ?? 0}';
    } catch (error) {
      emit(CreateGoalFailure(error.toString()));
    }
    emit(const CreateGoalInitial());
  }
}
