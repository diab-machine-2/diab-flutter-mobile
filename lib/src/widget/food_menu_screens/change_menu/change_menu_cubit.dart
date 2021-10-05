import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/food_suggest_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/food/food_client.dart';

import 'change_menu.dart';
import 'models/tab_item_enum.dart';

class ChangeMenuCubit extends Cubit<ChangeMenuState> {
  ChangeMenuCubit(this.repository) : super(const ChangeMenuInitial());

  final AppRepository repository;
  final FoodClient client = FoodClient();
  TabItem currentTab = TabItem.suggest;

  FoodModel? selectedFood;

  List<FoodModel> suggestFoods = [];
  List<FoodModel> recentlyFoods = [];
  List<FoodModel> favoriteFoods = [];
  List<FoodCategoryModel> categoryFoods = [];

  Future<void> refreshTab({TabItem? newTab}) async {
    if (newTab != null) {
      currentTab = newTab;
    }
    switch (newTab ?? currentTab) {
      case TabItem.suggest:
        await fetchSuggestFood();
        break;

      case TabItem.recently:
        await fetchFoodLatest();
        break;

      case TabItem.favorite:
        await fetchFoodFavorite();
        break;

      case TabItem.category:
        await fetchFoodCategory();
        break;

      default:
    }
  }

  Future<void> showLoading() async {
    await Future.delayed(const Duration());
    emit(const ChangeMenuLoading());
  }

  Future<void> fetchSuggestFood({String? id}) async {
    await showLoading();
    final ApiResult<FoodSuggestResponse> apiResult =
        await repository.getSuggestionFood(id ?? '');
    apiResult.when(success: (response) {
      if (response.data != null) {
        final List<FoodSuggestResponseData?>? data = response.data;
        //TODO: Convert data to List<FoodModel> and save it into suggestFoods
        emit(const ChangeMenuSuccess());
      }
    }, failure: (NetworkExceptions error) {
      emit(ChangeMenuFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ChangeMenuInitial());
  }

  Future<void> fetchFoodLatest() async {
    try {
      emit(const ChangeMenuLoading());
      final FoodDataModel foodDataModel = await client.fetchFoodLatest();
      recentlyFoods = foodDataModel.foods;
      emit(const ChangeMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(ChangeMenuFailure('$e'));
      } else {
        emit(ChangeMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
    emit(const ChangeMenuInitial());
  }

  Future<void> fetchFoodFavorite() async {
    try {
      emit(const ChangeMenuLoading());
      final FoodDataModel foodDataModel = await client.fetchFoodFavorite();
      favoriteFoods = foodDataModel.foods;
      emit(const ChangeMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(ChangeMenuFailure('$e'));
      } else {
        emit(ChangeMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }

  Future<void> fetchFoodCategory() async {
    try {
      emit(const ChangeMenuLoading());
      final List<FoodCategoryModel> foodCategoryModelList =
          await client.fetchCategory();
      categoryFoods = foodCategoryModelList;
      emit(const ChangeMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(ChangeMenuFailure('$e'));
      } else {
        emit(ChangeMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }

  Future<void> toogleFavorite(int foodModelIndex) async {
    late List<FoodModel> foods;
    switch (currentTab) {
      case TabItem.suggest:
        foods = suggestFoods;
        break;
      case TabItem.recently:
        foods = recentlyFoods;
        break;
      case TabItem.favorite:
        foods = favoriteFoods;
        break;
      default:
        foods = [];
    }
    if (foodModelIndex < 0 || foodModelIndex >= foods.length) return;
    final FoodModel foodModel = foods[foodModelIndex];
    emit(const ChangeMenuLoading());
    try {
      if (!foodModel.liked!) {
        await FoodClient().addFoodToFavorite(foodModel.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(foodModel.id);
      }
      foods[foodModelIndex] = foodModel.copyWith(liked: !foodModel.liked!);
      emit(const ChangeMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(ChangeMenuFailure('$e'));
      } else {
        emit(ChangeMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }

  Future<void> onChoseFood({required FoodModel newSelectedFood}) async {
    selectedFood = newSelectedFood;
    emit(const ChangeMenuDone());
    emit(const ChangeMenuInitial());
  }
}
