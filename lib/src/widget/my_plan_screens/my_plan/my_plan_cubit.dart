import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'models/plan_type.dart';

import 'my_plan.dart';

class MyPlanCubit extends Cubit<MyPlanState> {
  MyPlanCubit(this.repository) : super(const MyPlanInitial());

  final AppRepository repository;

  PlanType currentPlanType = PlanType.lesson;

  List<PlanType> planTypeList = [
    PlanType.goal,
    PlanType.lesson,
    PlanType.activity
  ];

  UserInfoResponse? userInfo;

  int get currentPlanTypeIndex {
    final int index = planTypeList.indexOf(currentPlanType);
    return index == -1 ? 0 : index;
  }

  String? get packageCode => userInfo?.data?.packageCode ?? '';
  String? get roadmapId => userInfo?.data?.roadmapId ?? '';
  int? get currentStudyWeek => userInfo?.data?.currentStudyWeek;

  void changePlanType(int newIndex) {
    currentPlanType = planTypeList[newIndex];
    emit(const MyPlanChangeType());
    emit(const MyPlanInitial());
  }

  Future<void> checkUserInfo() async {
    if (userInfo == null) {
      await getCurrentUserInfo();
    }
  }

  Future<void> getCurrentUserInfo() async {
    await Future.delayed(Duration.zero);
    emit(const MyPlanLoading());
    final ApiResult<UserInfoResponse> apiResult =
        await repository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      userInfo = response;
      emit(const MyPlanSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyPlanFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
