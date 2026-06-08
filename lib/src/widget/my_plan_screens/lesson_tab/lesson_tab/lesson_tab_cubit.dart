import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import '../../../../app_setting/app_setting.dart';
import '../../../../utils/const.dart';

import '../../my_plan/my_plan.dart';
import '../lesson_filter/models/filter_data.dart';
import 'lesson_tab.dart';
import 'lesson_search_cache.dart';
import 'models/lesson_type.dart';

class LessonTabCubit extends Cubit<LessonTabState> {
  LessonTabCubit(this.repository, this.myPlanCubit)
      : super(const LessonTabLoading());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;
  int numRecordOfPage = 10;

  /// Recommendation section state (\"Đề xuất\").
  /// type mapping:
  /// 0: Tất cả, 1: Theo dõi chỉ số, 2: Tinh thần, 3: Tâm lý hành vi,
  /// 4: Dinh dưỡng, 5: Bệnh lý, 6: Vận động.
  int recommendationType = 0;
  List<LessonSectionListResponseData?>? recommendationLessons;
  bool isRecommendationLoading = false;
  bool _hasLoadedRecommendationOnce = false;
  List<LessonSectionListResponseData?>? forYouLessons;
  bool isForYouLoading = false;
  bool _hasLoadedForYouOnce = false;

  final List<LessonType> lessonTypeList = [
    LessonType.route,
    LessonType.suggest
  ];

  FilterData filterData = FilterData();

  LessonType currentLessonType = LessonType.route;

  List<MyLessonResponseData?>? lessonsListRoadmap;
  List<MyLessonResponseData?>? lessonsListSuggest;

  List<MyLessonResponseData?>? get lessonsList {
    if (currentLessonTypeIndex == 0) {
      return lessonsListRoadmap ?? [];
    } else {
      return lessonsListSuggest ?? [];
    }
  }

  List<WeekStatesResponseData> weekStatesList = [];

  void refresh() {
    emit(const LessonTabSuccess());
    emit(const LessonTabInitial());
  }

  void onSelectWeek(int newIndex) {
    filterData.currentWeek = newIndex;
    lessonsListRoadmap = [];
    lessonsListSuggest = [];
    if (filterData.filterWithWeek) {
      getLessonsList(isShowLoading: true);
    } else {
      refresh();
    }
  }

  int get currentLessonTypeIndex {
    final int index = lessonTypeList.indexOf(currentLessonType);
    return index == -1 ? 0 : index;
  }

  int get currentWeekIndex => filterData.currentWeek ?? 1;

  bool get isFiltering => !filterData.isEmpty;

  void changeLessonType(int newIndex) {
    currentLessonType = lessonTypeList[newIndex];
    getLessonsList(isRefreshData: false, isShowLoading: true);
    emit(const LessonTabChangeType());
    emit(const LessonTabInitial());
  }

  void RefreshDataOfList() {
    lessonsListRoadmap?.clear();
    lessonsListSuggest?.clear();
  }

  Future<void> updateStatusLesson({
    required String lessonId,
    required int percentComplete,
  }) async {
    int learningStatus = Const.LESSON_LEARNING;
    if (percentComplete == 0) {
      learningStatus = Const.LESSON_NOT_LEARN;
    }
    if (percentComplete == 100) {
      learningStatus = Const.LESSON_LEARNT;
    }

    // Optimistic update across all 3 lesson lists so the UI reflects
    // the new status immediately without waiting for API calls.
    final int index =
        lessonsList?.indexWhere((e) => e?.id == lessonId) ?? -1;
    if (index >= 0) {
      lessonsList![index]!.percentComplete = percentComplete;
      lessonsList![index]!.learningStatus = learningStatus;
    }

    // Update "For You" list.
    if (forYouLessons != null) {
      for (final lesson in forYouLessons!) {
        if (lesson?.id == lessonId) {
          lesson?.percentComplete = percentComplete;
          lesson?.learningStatus = learningStatus;
        }
      }
    }

    // Update "Recommendations" list.
    if (recommendationLessons != null) {
      for (final lesson in recommendationLessons!) {
        if (lesson?.id == lessonId) {
          lesson?.percentComplete = percentComplete;
          lesson?.learningStatus = learningStatus;
        }
      }
    }

    LessonSearchCache.lessons = lessonsList;
    emit(const LessonTabSuccess());
    emit(const LessonTabInitial());
  }

  Future<void> getInitData(
      {bool isRefresh = false,
      bool showCurrentWeek = true,
      int? currentWeek,
      int currentPage = 1}) async {
    // Emit a loading state immediately so the UI doesn't render an empty
    // placeholder while async user info + API calls are still in progress.
    if (!isRefresh) {
      if (currentPage == 1) {
        emit(LessonTabLoading());
      } else {
        emit(const LessonTabLoadMore());
      }
    }

    if (myPlanCubit.userInfo == null || AppSettings.isReloadCurrentUserInfo) {
      await myPlanCubit.getCurrentUserInfo();
    }
    if (currentWeek != null) {
      filterData.currentWeek = currentWeek;
    } else {
      if (showCurrentWeek && myPlanCubit.isHasRoadmapUser) {
        filterData.currentWeek = myPlanCubit.currentStudyWeek!;
        if (filterData.currentWeek == -1) filterData.currentWeek = 0;
      } else {
        filterData.currentWeek = 0;
      }
    }

    await getLessonWeekStates(isRefresh: isRefresh);

    if (currentWeek != null) {
      Timer(const Duration(milliseconds: 100), () {
        emit(LessonTabWeekChanged(filterData.currentWeek!));
      });
    } else {
      if (showCurrentWeek && filterData.currentWeek != null) {
        Timer(const Duration(milliseconds: 100), () {
          emit(LessonTabWeekChanged(filterData.currentWeek!));
        });
      }
    }

    await getLessonsList(
        isRefresh: isRefresh, iPagingPage: currentPage, size: numRecordOfPage);
  }

  Future<void> onRefresh(
      {bool isRefresh = false,
      bool showCurrentWeek = false,
      int? currentWeek,
      currentPage = 1}) async {
    //  await getLessonWeekStates(isRefresh: isRefresh);

    if (currentWeek != null) {
      Timer(const Duration(milliseconds: 100), () {
        emit(LessonTabWeekChanged(filterData.currentWeek!));
      });
    } else {
      if (showCurrentWeek && filterData.currentWeek != null) {
        Timer(const Duration(milliseconds: 100), () {
          emit(LessonTabWeekChanged(filterData.currentWeek!));
        });
      }
    }

    RefreshDataOfList();
    await Future.wait([
      getLessonsList(
          isRefresh: isRefresh,
          iPagingPage: currentPage,
          size: numRecordOfPage),
      getForYouLessons(emitState: false),
      getRecommendationLessons(type: recommendationType, emitState: false),
    ]);
    emit(const LessonTabSuccess());
    emit(const LessonTabInitial());
  }

  Future<void> getLessonsList({
    bool isRefresh = false,
    bool isShowLoading = false,
    bool isRefreshData = true,
    int iPagingPage = 1,
    int size = 10,
  }) async {
    if (lessonsList?.isNotEmpty == true && !isRefreshData) {
      //   Timer(const Duration(milliseconds: 0), () {
      emit(LessonTabScrollToLesson(firstLessonIndex));
      //   });
      emit(const LessonTabSuccess());
      emit(const LessonTabInitial());
      return;
    }

    await Future.delayed(Duration.zero);
    if (isShowLoading) {
      if (iPagingPage == 1) {
        emit(LessonTabLoading());
      } else
        emit(const LessonTabLoadMore());
    }

    final LessonFilterRequest request = filterData.getRequest(
        type: currentLessonTypeIndex + 1, page: iPagingPage, size: size);
    final ApiResult<MyLessonResponse> apiResult =
        await repository.getLessonsList(request);
    apiResult.when(success: (MyLessonResponse response) {
      if (currentLessonTypeIndex == 0) {
        if (lessonsListRoadmap == null) {
          lessonsListRoadmap = response.data ?? [];
        } else {
          response.data?.forEach((element) {
            lessonsListRoadmap?.add(element);
          });
        }
      } else {
        if (lessonsListSuggest == null) {
          lessonsListSuggest = response.data ?? [];
        } else {
          response.data?.forEach((element) {
            lessonsListSuggest?.add(element);
          });
        }
      }
      // Cache for search page so it can reuse loaded data.
      LessonSearchCache.lessons = lessonsList;
      // emit(LessonTabScrollToLesson(response.firstLessonIndex));
      // Timer(const Duration(milliseconds: 0), () {
      //   emit(LessonTabScrollToLesson(response.firstLessonIndex));
      // });
      emit(const LessonTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonTabInitial());
  }

  /// Load recommendation lessons for Library \"Đề xuất\" section.
  Future<void> getRecommendationLessons({int? type, bool emitState = true}) async {
    final int requestType = type ?? recommendationType;
    recommendationType = requestType;
    // Only show inline loading spinner for the very first load;
    // subsequent refreshes (e.g. after completing a lesson) update silently.
    final bool shouldShowLoading = _hasLoadedRecommendationOnce;
    if (shouldShowLoading) {
      isRecommendationLoading = false;
    } else {
      isRecommendationLoading = true;
    }
    if (emitState) {
      emit(const LessonTabSuccess());
    }
    final ApiResult<List<LessonSectionListResponseData>> apiResult =
        await repository.getLessonModuleType(requestType);
    apiResult.when(success: (List<LessonSectionListResponseData> response) {
      // API now returns a list of LessonSectionListResponseData.
      recommendationLessons = response;
      _hasLoadedRecommendationOnce = true;
      isRecommendationLoading = false;
      if (emitState) {
        emit(const LessonTabSuccess());
      }
    }, failure: (NetworkExceptions error) {
      isRecommendationLoading = false;
      if (emitState) {
        emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
      }
    });
    if (emitState) {
      emit(const LessonTabInitial());
    }
  }

  /// Load personalized lessons for "Dành cho bạn" section.
  Future<void> getForYouLessons({bool emitState = true}) async {
    // Don't show inline loading spinner for the very first load
    // because global BotToast loading is already visible then.
    final bool shouldShowLoading = _hasLoadedForYouOnce;
    if (shouldShowLoading) {
      isForYouLoading = true;
      if (emitState) {
        emit(const LessonTabSuccess());
      }
    }
    final ApiResult<List<LessonSectionListResponseData>> apiResult =
        await repository.getRecommendedLessons();
    apiResult.when(success: (List<LessonSectionListResponseData> response) {
      forYouLessons = response;
      _hasLoadedForYouOnce = true;
      isForYouLoading = false;
      if (emitState) {
        emit(const LessonTabSuccess());
      }
    }, failure: (NetworkExceptions error) {
      isForYouLoading = false;
      if (emitState) {
        emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
      }
    });
    if (emitState) {
      emit(const LessonTabInitial());
    }
  }

  Future<void> scrollToLesson() async {
    emit(const LessonTabInitial());
    emit(LessonTabScrollToLesson(firstLessonIndex));
  }

  int get firstLessonIndex {
    if (lessonsList?.isNotEmpty != true) return 0;
    for (int index = 0; index < (lessonsList?.length ?? 0); index++) {
      if (lessonsList?[index]?.learningStatus != null &&
          lessonsList?[index]?.learningStatus != Const.LESSON_LEARNT) {
        return index;
      }
    }
    return 0;
  }

  Future<void> getLessonWeekStates({bool isRefresh = false}) async {
    //  await Future.delayed(Duration.zero);
    if (AppSettings.userInfo?.statistict?.lessons != null && !isRefresh) {
      weekStatesList.clear();
      for (final state in AppSettings.userInfo?.statistict?.lessons ?? []) {
        if (state != null) {
          weekStatesList.add(state);
        }
      }
      weekStatesList.sort((a, b) => (a.week ?? 0) - (b.week ?? 0));
    } else {
      final ApiResult<WeekStatesResponse> apiResult =
          await repository.getLessonWeekStates();
      apiResult.when(success: (WeekStatesResponse response) {
        weekStatesList.clear();
        for (final state in response.data ?? []) {
          if (state != null) {
            weekStatesList.add(state);
          }
        }
        weekStatesList.sort((a, b) => (a.week ?? 0) - (b.week ?? 0));
        //    emit(const LessonTabSuccess());
      }, failure: (NetworkExceptions error) {
        //    emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
      });
    }
    //  emit(const LessonTabInitial());
  }

  /// Silently re-fetch all lesson data in the background.
  /// No loading indicators or BotToast — the UI only updates when data arrives.
  Future<void> silentRefreshAll() async {
    await Future.wait([
      getLessonsList(isRefresh: true, isShowLoading: false),
      getForYouLessons(emitState: false),
      getRecommendationLessons(type: recommendationType, emitState: false),
    ]);
    emit(const LessonTabSuccess());
    emit(const LessonTabInitial());
  }
}
