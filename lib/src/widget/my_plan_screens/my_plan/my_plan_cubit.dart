import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/date_utils.dart';
import '../../../modal/user/user_model.dart';
import 'models/plan_type.dart';
import 'my_plan.dart';

class MyPlanCubit extends Cubit<MyPlanState> {
  MyPlanCubit(this.repository, this.index) : super(const MyPlanInitial()) {
    currentPlanType = index == 0 ? PlanType.goal : PlanType.lesson;
  }

  final int index;
  final AppRepository repository;

  late PlanType currentPlanType;

  List<PlanType> planTypeList = [PlanType.goal, PlanType.lesson, PlanType.activity];

  UserModel? userInfo;

  int get currentPlanTypeIndex {
    final int index = planTypeList.indexOf(currentPlanType);
    return index == -1 ? 0 : index;
  }

  PackageType get packageType => userInfo?.packageType ?? PackageType.free;
  String get roadmapId => userInfo?.roadMapId ?? '';
  int? get currentStudyWeek => userInfo?.ownPackage?.ownRoadmap?.currentWeek;

  bool get isFreeUser => packageType == PackageType.free;
  bool get isNoRoadmapUser => packageType == PackageType.no_road_map;
  bool get isHasRoadmapUser => packageType == PackageType.has_road_map && currentStudyWeek != null;

  void changePlanType(int newIndex) {
    currentPlanType = planTypeList[newIndex];
    emit(MyPlanChangeType(newIndex));
    emit(const MyPlanInitial());
  }

  Future<void> checkUserInfo({bool isRequired = false}) async {
    if (userInfo == null || isRequired) {
      await getCurrentUserInfo();
    }
  }

  Future<void> getCurrentUserInfo() async {
   // await Future.delayed(Duration.zero);
    userInfo = AppSettings.userInfo;
    AppSettings.currentDateTime = DateUtil.getCurrentNowInMillis();
    AppSettings.isReloadCurrentUserInfo = false;

    // emit(const MyPlanLoading());
    // final ApiResult<UserInfoResponse> apiResult = await repository.getCurrentUserInfo();
    // apiResult.when(success: (UserInfoResponse response) {
    //   userInfo = response;
    //   if (userInfo?.data?.currentDateTime != null) {
    //     AppSettings.currentDateTime = userInfo!.data!.currentDateTime!;
    //     AppSettings.isReloadCurrentUserInfo = false;
    //   }

    //   emit(const MyPlanSuccess());
    // }, failure: (NetworkExceptions error) {
    //   emit(MyPlanFailure(NetworkExceptions.getErrorMessage(error)));
    // });
  }
}
