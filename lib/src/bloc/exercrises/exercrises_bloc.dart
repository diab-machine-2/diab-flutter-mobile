import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/src/modal/exercrises/excercise_rank_model.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:medical/src/modal/exercrises/exercrise_summary.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_calo.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/modal/exercrises/exercrise_walk_summary.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/modal/exercrises/exercrises_categogy_request.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';

part 'exercrises_bloc_event.dart';
part 'exercrises_bloc_state.dart';

class ExercrisesBloc extends Bloc<ExercrisesEvent, ExercrisesState> {
  @override
  ExercrisesState get initialState => ExercrisesInitial();

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
  }

  Stream<ExercrisesState> fetchCategory(
      int page, List<ExercrisesCategoryModel> selectedModel) async* {
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
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> addCategory(
      ExercrisesCategoryModel selectedModel) async* {
    try {
      final currenState = state;
      ExercrisesListCategoryModel categories;
      List<ExercrisesCategoryModel> selectedCategories = [];
      ExercrisesListCategoryModel categorySearch;
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
        // selectedCategories = selectedCategories.where((element) =>
        //         selectedModel.categoryModel.id != element.categoryModel.id) ??
        //     [];
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
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> searchCategory(String key) async* {
    try {
      final currenState = state;
      ExercrisesListCategoryModel categories;
      ExercrisesListCategoryModel categorySearch;
      List<ExercrisesCategoryModel> selectedCategories = [];
      if (currenState is ExercrisesCategoryModelLoaded) {
        selectedCategories = currenState.selectedModel ?? [];
        categories = currenState.category;
        categorySearch = ExercrisesListCategoryModel(
            exerciseCategories: currenState.category.exerciseCategories
                .where((element) =>
                    element.category.toLowerCase().contains(key.toLowerCase()))
                .toList(),
            exerciseCategoryCommons: currenState
                .category.exerciseCategoryCommons
                .where((element) =>
                    element.category.toLowerCase().contains(key.toLowerCase()))
                .toList(),
            exerciseCategoryRegularlies: currenState
                .category.exerciseCategoryRegularlies
                .where((element) =>
                    element.category.toLowerCase().contains(key.toLowerCase()))
                .toList());
      }

      yield ExercrisesCategoryModelLoaded(
          category: categories,
          categorySearch: categorySearch,
          selectedModel: selectedCategories);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> fetchInputExercrises(
      String currentDateTime, String periodFilterType, int page) async* {
    try {
      final client = ExercrisesClient();
      final currenState = state;
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);

      if (currenState is ExercrisesDataLoaded) {
        if (currenState.inputExercrisesModel != null && page != 1) {
          model.inputs.insertAll(0, currenState.inputExercrisesModel);
        }
      }
      yield ExercrisesDataLoaded(
          inputExercrisesModel: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> fetchDataDaily(
    String currentDateTime,
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
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> fetchTimeTrend(
    String currentDateTime,
    String periodFilterType,
  ) async* {
    try {
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
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> fetchCaloTrend(
    String currentDateTime,
    String periodFilterType,
  ) async* {
    try {
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
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<ExercrisesState> fetchRank(
    String currentDateTime,
    String periodFilterType,
  ) async* {
    try {
      final client = ExercrisesClient();
      yield ExercrisesLoading();
      var model = await client.fetchRank(currentDateTime, periodFilterType);
      yield RankLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield ExercrisesError(message: e.message);
      } else {
        yield ExercrisesError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
