import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/exercrises/excercise_rank_model.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:medical/src/modal/exercrises/exercrise_summary.dart';
import 'package:medical/src/modal/exercrises/exercrise_result_summary.dart'; // Add this new import
import 'package:medical/src/modal/exercrises/exercrise_trend_calo.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/modal/exercrises/exercrise_walk_summary.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/response/exercise_lesson_response.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

part 'exercrises_bloc_event.dart';
part 'exercrises_bloc_state.dart';

class ExercrisesBloc extends Bloc<ExercrisesEvent, ExercrisesState> {
  ExercrisesBloc() : super(ExercrisesInitial());

  int get _currentWeek {
    if (AppSettings.userInfo?.ownPackage?.ownRoadmap?.currentWeek != null) {
      int week = AppSettings.userInfo!.ownPackage!.ownRoadmap!.currentWeek!;
      return week < 0 ? 0 : week;
    }
    return 0;
  }

  @override
  Stream<ExercrisesState> mapEventToState(ExercrisesEvent event) async* {
    if (event is FetchCategory) {
      yield* fetchCategory(event.page, event.selectedModel);
    }
    if (event is AddCategory) {
      yield* addCategory(event.selectedModel);
    }
    if (event is SearchCategory) {
      yield* searchCategory(event.key);
    }
    if (event is FetchInputExercrises) {
      yield* fetchInputExercrises(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is FetchDataDaily) {
      yield* fetchDataDaily(event.currentDateTime);
    }
    if (event is FetchTimeTrend) {
      yield* fetchTimeTrend(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchCaloTrend) {
      yield* fetchCaloTrend(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchRank) {
      yield* fetchRank(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchLessons) {
      yield* _fetchLessons();
    }
    if (event is FetchSupportExercises) {
      yield* _fetchSupportExercises();
    }
  }

  Stream<ExercrisesState> fetchCategory(
      int? page, List<ExercrisesCategoryModel>? selectedModel) async* {
    try {
      final client = ExercrisesClient();
      var model = await client.fetchCategory(page);
      yield ExercrisesCategoryModelLoaded(
          category: model.inputs, selectedModel: selectedModel ?? []);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> addCategory(
      ExercrisesCategoryModel selectedModel) async* {
    try {
      final ExercrisesState currenState = state;
      ExercrisesListCategoryModel? categories;
      List<ExercrisesCategoryModel> selectedCategories = [];
      ExercrisesListCategoryModel? categorySearch;
      bool hasMore = false;
      if (currenState is ExercrisesCategoryModelLoaded) {
        selectedCategories = currenState.selectedModel ?? [];
        categories = currenState.category;
        categorySearch = currenState.categorySearch;
      }
      final filter = selectedCategories
          .where((element) => selectedModel.categoryId == element.categoryId);
      if (filter.length == 0) {
        selectedCategories.add(selectedModel);
      } else {
        final index = selectedCategories.lastIndexWhere(
            (element) => selectedModel.categoryId == element.categoryId);
        selectedCategories.removeAt(index);
        selectedCategories.add(selectedModel);
      }
      yield ExercrisesCategoryModelLoaded(
          category: categories,
          selectedModel: selectedCategories,
          categorySearch: categorySearch);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> searchCategory(String? key) async* {
    try {
      final currentState = state;

      if (currentState is! ExercrisesCategoryModelLoaded || key == null) return;

      final lowerKey = key.toLowerCase();
      final categories = currentState.category!;
      final selectedCategories = currentState.selectedModel ?? [];

      List<ExercrisesCategoryModel> _filterOrFallback(
          List<ExercrisesCategoryModel> source,
          ) {
        final result = source
            .where((e) => e.category?.toLowerCase().contains(lowerKey) ?? false)
            .toList();

        return result.isNotEmpty
            ? result
            : source
            .where((e) => e.category?.toLowerCase().contains('khác') ?? false)
            .toList();
      }

      final categorySearch = ExercrisesListCategoryModel(
        exerciseCategories:
        _filterOrFallback(categories.exerciseCategories),
        exerciseCategoryCommons:
        _filterOrFallback(categories.exerciseCategoryCommons),
        exerciseCategoryRegularlies:
        _filterOrFallback(categories.exerciseCategoryRegularlies),
      );

      yield ExercrisesCategoryModelLoaded(
        category: categories,
        categorySearch: categorySearch,
        selectedModel: selectedCategories,
      );
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> fetchInputExercrises(
      String? currentDateTime, String? periodFilterType, int? page) async* {
    // periodFilterType =
    //     await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
    final client = ExercrisesClient();
    final ExercrisesState currenState = state;
    var model =
        await client.fetchInput(currentDateTime, periodFilterType, page);

    if (currenState is ExercrisesDataLoaded) {
      if (page != 1) {
        model.inputs.insertAll(0, currenState.inputExercrisesModel);
      }
    }
    yield ExercrisesDataLoaded(
        inputExercrisesModel: model.inputs, hasMore: model.hasMore);
  }

  Stream<ExercrisesState> fetchDataDaily(
    String? currentDateTime,
  ) async* {
    try {
      final client = ExercrisesClient();
      yield ExercrisesLoading();
      yield ExercriseDataDailyLoaded(
          exercriseSummaryModel:
              await client.fetchDailyExercrise(currentDateTime),
          exercriseWalkSummaryModel:
              await client.fetchWalkExercrise(currentDateTime));
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> fetchTimeTrend(
    String? currentDateTime,
    String? periodFilterType,
  ) async* {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
      final client = ExercrisesClient();
      yield ExercrisesLoading();
      var model = await client.fetchExercriseTimeTrend(
          currentDateTime, periodFilterType);
      yield TimeTrendTrendLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> fetchCaloTrend(
    String? currentDateTime,
    String? periodFilterType,
  ) async* {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
      final client = ExercrisesClient();
      yield ExercrisesLoading();
      var model = await client.fetchExercriseCaloTrend(
          currentDateTime, periodFilterType);
      yield CaloTrendLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> fetchRank(
    String? currentDateTime,
    String? periodFilterType,
  ) async* {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
      final client = ExercrisesClient();
      yield ExercrisesLoading();
      var model = await client.fetchRank(currentDateTime, periodFilterType);
      yield RankLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<ExercrisesState> _fetchLessons() async* {
    final learningClient = LearningClient();
    final lessonsResponse = await learningClient
        .fetchLesson(
      week: _currentWeek,
    )
        .catchError((e, s) {
      TrackingManager.recordError(e, s);
      return <LessonModel>[];
    }, test: (error) => true);

    if (state is ExercriseLessonsLoaded) {
      final currentState = state as ExercriseLessonsLoaded;
      yield currentState.copyWith(lessons: lessonsResponse);
    } else {
      yield ExercriseLessonsLoaded(lessons: lessonsResponse);
    }
  }

  Stream<ExercrisesState> _fetchSupportExercises() async* {
    try {
      yield ExercrisesLoading();

      final learningClient = LearningClient();
      final exerciseLessonResponse =
          await learningClient.fetchExerciseLessons();

      yield ExerciseSupportLessonsLoaded(
          exercises: exerciseLessonResponse.data);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      yield ExercrisesError(
          message: R.string.error_can_not_connect_to_server.tr());
    }
  }
}
