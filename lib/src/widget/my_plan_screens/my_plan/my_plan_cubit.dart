import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'models/plan_type.dart';

import 'my_plan.dart';

class MyPlanCubit extends Cubit<MyPlanState> {
  MyPlanCubit(this.repository) : super(const MyPlanInitial());

  final AppRepository repository;

  String packageCode = '';
  DateTime? packageTimeExpired;

  PlanType currentPlanType = PlanType.lesson;
  List<PlanType> planTypeList = [
    PlanType.goal,
    PlanType.lesson,
    PlanType.activity
  ];

  List<MyLessonResponseData?> lessonsList = [];

  int get currentPlanTypeIndex {
    final int index = planTypeList.indexOf(currentPlanType);
    return index == -1 ? 0 : index;
  }

  void changePlanType(int newIndex) {
    currentPlanType = planTypeList[newIndex];
    emit(const MyPlanChangeType());
    emit(const MyPlanInitial());
  }

  Future<void> getInitData({bool isRefresh = false}) async {
    await getCurrentUserInfo(isRefresh: isRefresh);
  }

  Future<void> getCurrentUserInfo({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const MyPlanLoading());
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

      emit(const MyPlanSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyPlanFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
