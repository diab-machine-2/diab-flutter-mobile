import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_smart_goal_request.dart';
import 'package:medical/src/model/response/create_smart_goal_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/create_smart_goal_data.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';

class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository, {required this.smartGoalDayList}) : super(const CreateGoalInitial());

  final AppRepository repository;
  final List<SmartGoalList?> smartGoalDayList;

  CreateSmartGoalData dataModel = CreateSmartGoalData();

  CreateGoalStatus currentStatus = CreateGoalStatus.select_type;

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

  bool get showDetail => !(currentStatus != CreateGoalStatus.setup || dataModel.type == ScheduleType.custom);

  SmartGoalList? getSmartGoalDataByType(ScheduleType type) {
    final int index = smartGoalDayList.indexWhere((element) => element?.type == type.typeIndex);
    if (index == -1) return null;
    return smartGoalDayList[index];
  }

  void fillInitialData(ScheduleType selectedType) {
    final SmartGoalList? smartGoalData = getSmartGoalDataByType(selectedType);
    dataModel.fillData(selectedType, smartGoalData);
  }

  Future<void> setupGoal({required ScheduleType selectedType, int? subType}) async {
    //When chose a smart goal type for the first time
    if (dataModel.cachedType == null ||
        selectedType != dataModel.cachedType ||
        selectedType == dataModel.cachedType && subType != dataModel.cachedSubType) {
      dataModel.resetData();
      fillInitialData(selectedType);
    }
    dataModel.cachedType = null;
    dataModel.cachedSubType = null;
    dataModel.type = selectedType;
    dataModel.subType = subType;
    if (selectedType != null && selectedType != ScheduleType.custom) {
      dataModel.goalRecordType = GoalRecordType.frequency;
    }
    currentStatus = CreateGoalStatus.setup;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onToggleRepeat() {
    dataModel.isRepeat = !dataModel.isRepeat;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatType(String selectedRepeatType) {
    dataModel.repeatType = RepeatTypeExtend.getTypeFromString(selectedRepeatType);
    if (dataModel.repeatType == RepeatType.day) {
      dataModel.repeatDayList.clear();
    }
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatDay(List<String> selectedDayList) {
    dataModel.repeatDayList = selectedDayList.map((e) => DayInWeekExtend.getDayInWeekFromString(e)).toList();
    dataModel.repeatDayList.sort((a, b) => a.index - b.index);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onSelectStatus(CreateGoalStatus newStatus) {
    if (newStatus == currentStatus) return;

    if (currentStatus == CreateGoalStatus.select_type && dataModel.type == null) return;

    if (newStatus == CreateGoalStatus.complete) {
      if (!isValid) {
        currentStatus = CreateGoalStatus.setup;
        emit(const CreateGoalSuccess());
        emit(const CreateGoalInitial());
        return;
      }
    }

    if (newStatus == CreateGoalStatus.select_type) {
      dataModel.cachedType = dataModel.type;
      dataModel.cachedSubType = dataModel.subType;
    }

    currentStatus = newStatus;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  Future<void> onTapNext() async {
    if (currentStatus == null) return;
    if (currentStatus == CreateGoalStatus.setup) {
      if (!isValid) return;
      currentStatus = CreateGoalStatus.complete;
      emit(const CreateGoalSuccess());
    } else if (currentStatus == CreateGoalStatus.complete) {
      await createSmartGoal();
      emit(const CreateGoalCompleted());
    }
    emit(const CreateGoalInitial());
  }

  Future<void> createSmartGoal() async {
    emit(const CreateGoalLoading());
    late final ApiResult<CreateSmartGoalResponse> apiResult;
    apiResult = await repository.createSmartGoal(dataModel.request ?? CreateSmartGoalRequest());
    apiResult.when(success: (CreateSmartGoalResponse response) {
      if (response.meta?.success ?? false) {
        emit(const CreateGoalSuccess());
      } else {
        emit(CreateGoalFailure(response.error?.message ?? R.string.error));
      }
    }, failure: (NetworkExceptions error) {
      emit(CreateGoalFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const CreateGoalInitial());
  }
}
