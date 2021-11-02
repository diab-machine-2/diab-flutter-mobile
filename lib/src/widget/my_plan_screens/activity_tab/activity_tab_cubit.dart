import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';

import '../my_plan/models/time_data.dart';
import 'activity_tab.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository) : super(const ActivityTabInitial());

  final AppRepository repository;

  List<dynamic> data = [];

  TimeData? timeData;

  String packageCode = '';
  DateTime? packageTimeExpired;

  void onSelectWeek(int newIndex) {
    timeData?.currentWeekIndex = newIndex;
    emit(const ActivityTabSuccess());
    emit(const ActivityTabInitial());
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    data.add('sdfs');
    emit(const ActivityTabSuccess());
    emit(const ActivityTabInitial());
  }

  Future<void> getCurrentUserInfo({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const ActivityTabLoading());
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
      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
