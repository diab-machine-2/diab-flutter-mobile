import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
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
import 'package:easy_localization/easy_localization.dart';

part 'food_bloc_event.dart';
part 'food_bloc_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  FoodBloc() : super(FoodInitial());

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
                R.string.error_can_not_connect_to_server.tr());
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
                R.string.error_can_not_connect_to_server.tr());
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
                R.string.error_can_not_connect_to_server.tr());
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
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> searchFood(String keyword, int page) async* {
    try {
      if (page == 1) {
        yield FoodLoading();
      }
      final client = FoodClient();
      final FoodState currenState = state;
      var model = await client.fetchFoodCategory(null, keyword, page);

      if (currenState is FoodSearchLoaded) {
        if (currenState.searchModel != null && page != 1) {
          model.foods.insertAll(0, currenState.searchModel!.foods);
        }
      }
      yield FoodSearchLoaded(searchModel: model);
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchInputFood(
      String currentDateTime, String periodFilterType, int page) async* {
    try {
      final client = FoodClient();
      final FoodState currenState = state;
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);

      if (currenState is FoodInputLoaded) {
        if (page != 1) {
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
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> likeFood(FoodModel food, int index) async* {
    try {
      final FoodState currenState = state;

      if (currenState is FoodLoaded) {
        FoodDataModel model;
        model = currenState.model;
        model.foods[index] = food;
        yield FoodLoaded(model: model);
      } else if (currenState is FoodSearchLoaded) {
        FoodCategoryDataModel? model;
        model = currenState.searchModel;
        model!.foods[index] = food;
        yield FoodSearchLoaded(searchModel: model);
      }
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(
            message:
                R.string.error_can_not_connect_to_server.tr());
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
                R.string.error_can_not_connect_to_server.tr());
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
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticDetail(
      String? currentDateTime, String? periodFilterType) async* {
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
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticTrend(
      String? currentDateTime, String? periodFilterType) async* {
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
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticDistribute(
      String? currentDateTime, String? periodFilterType) async* {
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
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
