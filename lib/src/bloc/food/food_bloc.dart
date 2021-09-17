import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/food/food_statistic_diet_model.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
part 'food_bloc_event.dart';
part 'food_bloc_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  @override
  FoodState get initialState => FoodInitial();

  @override
  Stream<FoodState> mapEventToState(FoodEvent event) async* {
    if (event is FetchFoodLatest) {
      yield* fetchFoodLatest(event.page);
    }
    if (event is FetchFoodFavorite) {
      yield* fetchFoodFavorite(event.page);
    }
    if (event is FetchFoodCategory) {
      yield* fetchFoodCategory(event.page);
    }
    if (event is FetchFood) {
      yield* fetchFood(event.page);
    }
    if (event is FetchSearchFood) {
      yield* searchFood(event.keyword, event.page);
    }
    if (event is FetchInputFood) {
      yield* fetchInputFood(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is LikeFood) {
      yield* likeFood(event.model, event.index);
    }
    if (event is FetchStatisticCalo) {
      yield* fetchStatisticCalo();
    }
    if (event is FetchStatisticCarb) {
      yield* fetchStatisticCarb();
    }
    if (event is FetchStatisticDetail) {
      yield* fetchStatisticDetail(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchStatisticTrend) {
      yield* fetchStatisticTrend(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchStatisticDistribute) {
      yield* fetchStatisticDistribute(
          event.currentDateTime, event.periodFilterType);
    }
  }

  Stream<FoodState> fetchFoodLatest(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodLoaded(model: await client.fetchFoodLatest());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchFoodFavorite(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodLoaded(model: await client.fetchFoodFavorite());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchFoodCategory(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodCategoryLoaded(model: await client.fetchCategory());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchFood(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodLoaded(model: await client.fetchFood());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> searchFood(String keyword, int page) async* {
    try {
      if (page == 1) {
        yield FoodLoading();
      }
      final client = FoodClient();
      final currenState = state;
      var model = await client.fetchFoodCategory(null, keyword, page);

      if (currenState is FoodSearchLoaded) {
        if (currenState.searchModel != null && page != 1) {
          model.foods.insertAll(0, currenState.searchModel.foods);
        }
      }
      yield FoodSearchLoaded(searchModel: model);
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchInputFood(
      String currentDateTime, String periodFilterType, int page) async* {
    try {
      final client = FoodClient();
      final currenState = state;
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);

      if (currenState is FoodInputLoaded) {
        if (currenState.inputs != null && page != 1) {
          model.inputs.insertAll(0, currenState.inputs);
        }
      }
      yield FoodInputLoaded(inputs: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> likeFood(FoodModel food, int index) async* {
    try {
      final currenState = state;

      if (currenState is FoodLoaded) {
        FoodDataModel model;
        model = currenState.model;
        model.foods[index] = food;
        yield FoodLoaded(model: model);
      } else if (currenState is FoodSearchLoaded) {
        FoodCategoryDataModel model;
        model = currenState.searchModel;
        model.foods[index] = food;
        yield FoodSearchLoaded(searchModel: model);
      }
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchStatisticCalo() async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticCaloLoaded(model: await client.fetchStatisticCalo());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchStatisticCarb() async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticCarbLoaded(model: await client.fetchStatisticCarb());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchStatisticDetail(
      String currentDateTime, String periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticDetailLoaded(
          model: await client.fetchStatisticDetail(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchStatisticTrend(
      String currentDateTime, String periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticTrendLoaded(
          model: await client.fetchStatisticTrend(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<FoodState> fetchStatisticDistribute(
      String currentDateTime, String periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticDistributeLoaded(
          model: await client.fetchStatisticDistribute(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
