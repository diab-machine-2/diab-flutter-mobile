import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/repo/food/food_client.dart';

import 'category_menu.dart';

class CategoryMenuCubit extends Cubit<CategoryMenuState> {
  CategoryMenuCubit({required this.repository, required this.category})
      : super(const CategoryMenuInitial());

  final AppRepository repository;
  final FoodSubCategoryModel category;
  final FoodClient client = FoodClient();

  List<FoodModel> foods = [];

  Future<void> fetchFoodCategory() async {
    try {
      emit(const CategoryMenuLoading());
      final FoodCategoryDataModel foodCategoryModelList =
          await client.fetchFoodCategory(category.id, null, null);
      foods = foodCategoryModelList.foods;
      emit(const CategoryMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(CategoryMenuFailure('$e'));
      } else {
        emit(
            CategoryMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }

  Future<void> toogleFavorite(int foodModelIndex) async {
    final FoodModel foodModel = foods[foodModelIndex];
    emit(const CategoryMenuLoading());
    try {
      if (!foodModel.liked!) {
        await FoodClient().addFoodToFavorite(foodModel.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(foodModel.id);
      }
      foods[foodModelIndex] = foodModel.copyWith(liked: !foodModel.liked!);
      emit(const CategoryMenuSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(CategoryMenuFailure('$e'));
      } else {
        emit(CategoryMenuFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }
}
