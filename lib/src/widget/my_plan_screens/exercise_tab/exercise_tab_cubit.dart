import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
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

  List<dynamic> data = ['sdfs'];

  TimeData? timeData;

  String packageCode = '';
  DateTime? packageTimeExpired;

  void onSelectWeek(int newIndex) {
    timeData?.currentWeekIndex = newIndex;
    emit(const ExerciseTabSuccess());
    emit(const ExerciseTabInitial());
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    data.clear();
    emit(const ExerciseTabSuccess());
    emit(const ExerciseTabInitial());
  }

  Future<void> getCurrentUserInfo({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const ExerciseTabLoading());
    }
    final ApiResult<UserInfoResponse> apiResult =
        await repository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      packageCode = response.data?.packageCode ?? '';
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
}
