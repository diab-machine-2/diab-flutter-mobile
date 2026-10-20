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
  int numRecordOfPage = 1000;

  /// Recommendation section state (\"Đề xuất\").
  /// type mapping:
  /// 0: Tất cả, 1: Theo dõi chỉ số, 2: Tinh thần, 3: Tâm lý hành vi,
  /// 4: Dinh dưỡng, 5: Bệnh lý, 6: Vận động.
  int recommendationType = 0;
  List<LessonSectionListResponseData?>? recommendationLessons;

  /// Skeleton in place of the list — only while the selected chip has
  /// nothing to show yet; refreshes keep the current rows.
  bool isRecommendationLoading = false;

  /// The selected chip failed with nothing to show: the section shows an
  /// inline "Thử lại" instead of the rows.
  bool hasRecommendationError = false;

  /// Lists already fetched this session, per chip, so switching back shows
  /// them at once (then revalidates in the background).
  final Map<int, List<LessonSectionListResponseData?>> _recommendationByType =
      {};

  /// Bumped on every request; a response from an older one is dropped so
  /// tapping chips quickly can't leave another chip's list on screen.
  int _recommendationRequestId = 0;

  /// Newest request id per chip, so an older answer for the same chip can't
  /// overwrite a newer one in [_recommendationByType].
  final Map<int, int> _latestRecommendationIdByType = {};
  List<LessonSectionListResponseData?>? forYouLessons;
  bool isForYouLoading = false;

  final List<LessonType> lessonTypeList = [
    LessonType.route,
    LessonType.suggest
  ];

  FilterData filterData = FilterData();

  LessonType currentLessonType = LessonType.route;

  /// True while the main lesson list is being fetched with nothing to show
  /// yet — the page shows its skeleton instead of the empty placeholder.
  bool isLessonsLoading = false;

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

    // Update "Recommendations" lists (every chip fetched this session).
    for (final list in {
      recommendationLessons,
      ..._recommendationByType.values,
    }) {
      for (final lesson in list ?? const <LessonSectionListResponseData?>[]) {
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
    // Set here too (not only in getLessonsList) so the skeleton covers the
    // user-info step before the list request starts.
    if (currentPage == 1 && lessonsList?.isNotEmpty != true) {
      isLessonsLoading = true;
    }
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

    // Week states only feed the week selector, which is hidden for now
    // (_weekScrollController isn't attached). Skipping the call saves a
    // request before the lesson list; restore it with the selector.
    // await getLessonWeekStates(isRefresh: isRefresh);

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
    int size = 1000,
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

    if (iPagingPage == 1 && lessonsList?.isNotEmpty != true) {
      isLessonsLoading = true;
    }
    final LessonFilterRequest request = filterData.getRequest(
        type: currentLessonTypeIndex + 1, page: iPagingPage, size: size);
    final ApiResult<MyLessonResponse> apiResult =
        await repository.getLessonsList(request);
    isLessonsLoading = false;
    apiResult.when(success: (MyLessonResponse response) {
      // Page 1 replaces the list: appending doubled every lesson when a
      // refresh (silentRefreshAll after finishing a lesson, or a pull during
      // the first load) answered on top of an existing list.
      final List<MyLessonResponseData?> page = response.data ?? [];
      if (currentLessonTypeIndex == 0) {
        if (iPagingPage == 1 || lessonsListRoadmap == null) {
          lessonsListRoadmap = List.of(page);
        } else {
          lessonsListRoadmap!.addAll(page);
        }
      } else {
        if (iPagingPage == 1 || lessonsListSuggest == null) {
          lessonsListSuggest = List.of(page);
        } else {
          lessonsListSuggest!.addAll(page);
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
  ///
  /// A [type] different from the current chip switches it: that chip's list
  /// from earlier this session shows at once, otherwise a skeleton until the
  /// request answers. Re-requesting the current chip (refreshes) keeps its
  /// rows on screen. A failure with nothing to show becomes an inline retry
  /// rather than a toast; a failed refresh keeps the rows it had.
  Future<void> getRecommendationLessons({int? type, bool emitState = true}) async {
    final int requestType = type ?? recommendationType;
    if (requestType != recommendationType) {
      // Another chip's rows must never sit under the newly selected chip.
      recommendationLessons = _recommendationByType[requestType];
    }
    recommendationType = requestType;
    final int requestId = ++_recommendationRequestId;
    _latestRecommendationIdByType[requestType] = requestId;
    isRecommendationLoading = recommendationLessons == null;
    hasRecommendationError = false;
    // A placeholder going away is never a silent change, so a refresh that
    // took over a chip tap still updates the screen as soon as it answers.
    final bool replacesPlaceholder = isRecommendationLoading;
    if (emitState) {
      emit(const LessonTabSuccess());
      emit(const LessonTabInitial());
    }

    final ApiResult<List<LessonSectionListResponseData>> apiResult =
        await repository.getLessonModuleType(requestType);
    if (isClosed) return;

    // Overtaken by a later tap: the rows are still right for their own
    // chip, so keep them for when the user goes back to it.
    final List<LessonSectionListResponseData>? data =
        apiResult.whenOrNull(success: (response) => response);
    if (data != null &&
        _latestRecommendationIdByType[requestType] == requestId) {
      _recommendationByType[requestType] = data;
    }
    if (requestId != _recommendationRequestId) return;

    if (data != null) {
      recommendationLessons = data;
    } else {
      hasRecommendationError = recommendationLessons == null;
    }
    isRecommendationLoading = false;
    if (emitState || replacesPlaceholder) {
      emit(const LessonTabSuccess());
      emit(const LessonTabInitial());
    }
  }

  /// Load personalized lessons for "Dành cho bạn" section.
  Future<void> getForYouLessons({bool emitState = true}) async {
    // Skeleton only while there is nothing to show yet; refreshes keep the
    // current cards until the new ones arrive.
    isForYouLoading = forYouLessons == null;
    if (emitState) {
      emit(const LessonTabSuccess());
    }
    final ApiResult<List<LessonSectionListResponseData>> apiResult =
        await repository.getRecommendedLessons();
    apiResult.when(success: (List<LessonSectionListResponseData> response) {
      forYouLessons = response;
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
