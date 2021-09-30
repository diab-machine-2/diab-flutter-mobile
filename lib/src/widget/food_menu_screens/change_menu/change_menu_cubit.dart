import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
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

  Future<void> fetchSuggestFood() async {}

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

  Future<void> likeFood({FoodModel? foodModel}) async {
    if (foodModel == null) return;
    emit(const ChangeMenuLoading());
    try {
      if (!foodModel.liked!) {
        await FoodClient().addFoodToFavorite(foodModel.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(foodModel.id);
      }
      await refreshTab();
      emit(const ChangeMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(ChangeMenuFailure('$e'));
      } else {
        emit(ChangeMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }

  Future<void> onChoseFood({required FoodModel foodModel}) async {
    emit(const ChangeMenuLoading());
    await Future.delayed(const Duration(seconds: 2));
    emit(const ChangeMenuDone());
  }
}
