import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';

import '../my_plan/models/time_data.dart';
import 'exercise_tab.dart';

class ExerciseTabCubit extends Cubit<ExerciseTabState> {
  ExerciseTabCubit(this.repository) : super(const ExerciseTabInitial());

  final AppRepository repository;

  TimeData? timeData;

  String roadmapId = '';
  String packageCode = '';
  DateTime? packageTimeExpired;
  List<ExerciseMovementResponseData?>? exerciseList;

  void onSelectWeek(int newIndex) {
    timeData?.currentWeekIndex = newIndex;
    emit(const ExerciseTabSuccess());
    emit(const ExerciseTabInitial());
  }

  Future<void> initData() async {
    await getCurrentUserInfo();
    if (roadmapId.isEmpty) {
      emit(const ExerciseTabRoadmapEmpty());
      emit(const ExerciseTabInitial());
      return;
    }
    getExerciseMovement();
  }

  Future<void> getCurrentUserInfo({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const ExerciseTabLoading());
    }
    final ApiResult<UserInfoResponse> apiResult =
        await repository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      packageCode = response.data?.packageCode ?? '';
      roadmapId = response.data?.roadmapId ?? '';
      final String packageTimeExpiredText =
          response.data?.packageTimeExpired ?? '';
      if (packageTimeExpiredText.isNotEmpty) {
        packageTimeExpired = DateUtil.parseStringToDate(
          packageTimeExpiredText,
          Const.DATE_TIME_SV_FORMAT,
        );
      }
      if (packageCode == Const.PRO && packageTimeExpired != null) {
        timeData = TimeData(
          startDate: DateTime.now(),
          endDate: packageTimeExpired!,
        );
      }
      emit(const ExerciseTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> getExerciseMovement({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const ExerciseTabLoading());
    }
    final ApiResult<ExerciseMovementResponse> apiResult =
        await repository.getExerciseMovement(roadmapId);
    apiResult.when(success: (ExerciseMovementResponse response) {
      exerciseList = response.data ?? [];
      emit(const ExerciseTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseTabInitial());
  }
}
