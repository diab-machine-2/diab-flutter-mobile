import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/food_suggest_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/food/food_client.dart';

import 'change_menu.dart';

class ChangeMenuCubit extends Cubit<ChangeMenuState> {
  ChangeMenuCubit(this.repository, {required this.initFood})
      : super(const ChangeMenuInitial());

  final AppRepository repository;
  final FoodClient client = FoodClient();

  FoodModel? initFood;

  FoodModel? selectedFood;

  List<FoodModel> suggestFoods = [];

  Future<void> showLoading() async {
    await Future.delayed(const Duration());
    emit(const ChangeMenuLoading());
  }

  Future<void> fetchSuggestFood({
    required String dateCode,
    required int timeCode,
  }) async {
    await showLoading();
    final ApiResult<FoodSuggestResponse> apiResult =
        await repository.getSuggestionFood(
      foodMenuCode: initFood?.code ?? initFood?.foodMenuCode ?? '',
      foodId: initFood?.id ?? '',
      dateCode: dateCode,
      timeCode: timeCode,
      isUseReplacedFood: true,
    );
    apiResult.when(success: (response) {
      if (response.data != null) {
        suggestFoods = response.foodModelList;
        emit(const ChangeMenuSuccess());
      }
    }, failure: (NetworkExceptions error) {
      emit(ChangeMenuFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ChangeMenuInitial());
  }

  Future<void> toogleFavorite(int foodModelIndex) async {
    if (foodModelIndex < 0 || foodModelIndex >= suggestFoods.length) return;
    final FoodModel foodModel = suggestFoods[foodModelIndex];
    emit(const ChangeMenuLoading());
    try {
      if (!foodModel.liked!) {
        await FoodClient().addFoodToFavorite(foodModel.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(foodModel.id);
      }
      suggestFoods[foodModelIndex] =
          foodModel.copyWith(liked: !foodModel.liked!);
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
