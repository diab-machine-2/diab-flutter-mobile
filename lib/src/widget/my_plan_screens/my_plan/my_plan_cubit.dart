import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'models/lesson_type.dart';
import 'models/plan_type.dart';

import 'models/time_data.dart';
import 'my_plan.dart';

class MyPlanCubit extends Cubit<MyPlanState> {
  MyPlanCubit(this.repository) : super(const MyPlanInitial());

  final AppRepository repository;

  String packageCode = '';
  DateTime? packageTimeExpired;

  TimeData? timeData;

  PlanType currentPlanType = PlanType.lesson;
  List<PlanType> planTypeList = [PlanType.goal, PlanType.lesson];

  LessonType currentLessonType = LessonType.route;
  final List<LessonType> lessonTypeList = [
    LessonType.route,
    LessonType.suggest
  ];

  List<String> keyWordList = [
    'Dinh dưỡng',
    'Đường huyết',
    'Cân nặng',
    'Huyết áp',
    'Cảm xúc',
    'Vận động',
    'HbA1c',
  ];

  List<MyLessonResponseData?> lessonsList = [];

  int get currentPlanTypeIndex {
    final int index = planTypeList.indexOf(currentPlanType);
    return index == -1 ? 0 : index;
  }

  int get currentLessonTypeIndex {
    final int index = lessonTypeList.indexOf(currentLessonType);
    return index == -1 ? 0 : index;
  }

  void changePlanType(int newIndex) {
    currentPlanType = planTypeList[newIndex];
    emit(const MyPlanChangeType());
    emit(const MyPlanInitial());
  }

  void changeLessonType(int newIndex) {
    currentLessonType = lessonTypeList[newIndex];
    emit(const MyPlanChangeType());
    emit(const MyPlanInitial());
  }

  void checkPlanList() {
    if (packageCode.isNotEmpty && packageCode != Const.BASIC) {
      planTypeList = [
        PlanType.goal,
        PlanType.lesson,
        PlanType.activity,
      ];
    } else {
      planTypeList = [
        PlanType.goal,
        PlanType.lesson,
      ];
    }
    emit(const MyPlanChangeType());
    emit(const MyPlanInitial());
  }

  void onSelectWeek(int newIndex) {
    timeData?.currentWeekIndex = newIndex;
    emit(const MyPlanSuccess());
    emit(const MyPlanInitial());
  }

  Future<void> getInitData({bool isRefresh = false}) async {
    await getCurrentUserInfo(isRefresh: isRefresh);
    await getLessonsList(isRefresh: isRefresh);
  }

  Future<void> getLessonsList({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const MyPlanLoading());
    }
    final ApiResult<MyLessonResponse> apiResult =
        await repository.getLessonsList(currentLessonTypeIndex);
    apiResult.when(success: (MyLessonResponse response) {
      lessonsList = response.data ?? [];
      emit(const MyPlanSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyPlanFailure(NetworkExceptions.getErrorMessage(error)));
    });
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
      if (packageCode == Const.PREMIUM && packageTimeExpired != null) {
        timeData = TimeData(
          startDate: DateTime.now(),
          endDate: packageTimeExpired!,
        );
      }
      checkPlanList();
      emit(const MyPlanSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyPlanFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
