import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';

import '../lesson_filter/models/filter_data.dart';
import '../my_plan/models/time_data.dart';
import 'lesson_tab.dart';
import 'models/lesson_type.dart';

class LessonTabCubit extends Cubit<LessonTabState> {
  LessonTabCubit(this.repository) : super(const LessonTabInitial());

  final AppRepository repository;

  final List<LessonType> lessonTypeList = [
    LessonType.route,
    LessonType.suggest
  ];

  FilterData filterData = FilterData();

  LessonType currentLessonType = LessonType.route;

  List<MyLessonResponseData?>? lessonsList;

  TimeData? timeData;

  String packageCode = '';
  DateTime? packageTimeExpired;

  void refresh() {
    emit(const LessonTabSuccess());
    emit(const LessonTabInitial());
  }

  void onSelectWeek(int newIndex) {
    timeData?.currentWeekIndex = newIndex;
    refresh();
  }

  int get currentLessonTypeIndex {
    final int index = lessonTypeList.indexOf(currentLessonType);
    return index == -1 ? 0 : index;
  }

  void changeLessonType(int newIndex) {
    currentLessonType = lessonTypeList[newIndex];
    getLessonsList();
    emit(const LessonTabChangeType());
    emit(const LessonTabInitial());
  }

  Future<void> getInitData() async {
    await getCurrentUserInfo();
    getLessonsList();
  }

  Future<void> getLessonsList({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const LessonTabLoading());
    }
    final ApiResult<MyLessonResponse> apiResult =
        await repository.getLessonsList(currentLessonTypeIndex + 1);
    apiResult.when(success: (MyLessonResponse response) {
      lessonsList = response.data ?? [];
      emit(const LessonTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonTabInitial());
  }

  Future<void> getCurrentUserInfo({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const LessonTabLoading());
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
      emit(const LessonTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
