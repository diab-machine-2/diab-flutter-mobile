import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';

import '../lesson_filter/models/filter_data.dart';
import 'lesson_tab.dart';
import 'models/completion_status.dart';
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

  String packageCode = '';
  DateTime? packageTimeExpired;

  List<CompletionStatus> weekList = [];

  void refresh() {
    emit(const LessonTabSuccess());
    emit(const LessonTabInitial());
  }

  void onSelectWeek(int newIndex) {
    filterData.week = newIndex;
    if (filterData.filterWithWeek) {
      getLessonsList();
    } else {
      refresh();
    }
  }

  int get currentLessonTypeIndex {
    final int index = lessonTypeList.indexOf(currentLessonType);
    return index == -1 ? 0 : index;
  }

  int get currentWeekIndex => filterData.week ?? 1;

  void changeLessonType(int newIndex) {
    currentLessonType = lessonTypeList[newIndex];
    getLessonsList();
    emit(const LessonTabChangeType());
    emit(const LessonTabInitial());
  }

  void generateWeek() {
    weekList = List.generate(52, (index) {
      final int current = filterData.week ?? 1;
      if (index > current) return CompletionStatus.not_start_yet;
      if (index == current)
        return CompletionStatus.studying;
      else
        return CompletionStatus.completed;
    });
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
    final LessonFilterRequest request =
        filterData.getRequest(type: currentLessonTypeIndex + 1);
    final ApiResult<MyLessonResponse> apiResult =
        await repository.getLessonsList(request);
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
      filterData.roadmapId = response.data?.roadmapId ?? '';
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
        filterData.week = (response.data?.currentStudyWeek ?? 1) - 1;
        generateWeek();
      }
      emit(const LessonTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
