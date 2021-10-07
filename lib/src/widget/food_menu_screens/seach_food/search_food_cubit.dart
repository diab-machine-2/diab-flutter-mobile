import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/repo/food/food_client.dart';

import 'search_food.dart';

class SearchFoodCubit extends Cubit<SearchFoodState> {
  SearchFoodCubit(this.repository) : super(const SearchFoodInitial());

  final AppRepository repository;
  final client = FoodClient();
  String currentKeyWord = '';
  int currentPage = 1;
  bool hasMore = false;

  List<FoodModel> foods = [];

  //Put nothing to get list food
  //Put keyWord to search with keyWord in page 1
  //Put isLoadMore: true to loadMore data with current keyWord
  Future<bool> searchFood({
    String keyWord = '',
    bool isLoadMore = false,
  }) async {
    currentPage = isLoadMore ? (currentPage + 1) : 1;
    currentKeyWord = isLoadMore ? currentKeyWord : keyWord;
    emit(const SearchFoodLoading());
    try {
      final FoodCategoryDataModel foodCategoryDataModel =
          await client.fetchFoodCategory(null, keyWord, currentPage);
      hasMore = foodCategoryDataModel.hasMore ?? false;
      if (isLoadMore) {
        foods.addAll(foodCategoryDataModel.foods);
      } else {
        foods = foodCategoryDataModel.foods;
      }
      emit(const SearchFoodSuccess());
      return true;
    } catch (e, _) {
      if (e is Error) {
        emit(SearchFoodFailure('$e'));
      } else {
        emit(SearchFoodFailure(R.string.error_can_not_connect_to_server.tr()));
      }
      return false;
    }
  }

  Future<void> toogleFavorite(int foodModelIndex) async {
    final FoodModel foodModel = foods[foodModelIndex];
    emit(const SearchFoodLoading());
    try {
      if (!foodModel.liked!) {
        await FoodClient().addFoodToFavorite(foodModel.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(foodModel.id);
      }
      foods[foodModelIndex] = foodModel.copyWith(liked: !foodModel.liked!);
      emit(const SearchFoodSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(SearchFoodFailure('$e'));
      } else {
        emit(SearchFoodFailure(R.string.error_can_not_connect_to_server.tr()));
      }
    }
  }
}
