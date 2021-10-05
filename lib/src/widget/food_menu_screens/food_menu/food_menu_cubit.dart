import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'food_menu.dart';

class FoodMenuCubit extends Cubit<FoodMenuState> {
  FoodMenuCubit(this.repository) : super(const FoodMenuInitial());

  final AppRepository repository;

  MenuResponseFood? menuResponseFood;
  List<MenuResponseListdayfood?> listDayFood = [];
  int currentDayInWeek = 0;

  MenuResponseListdayfood? get currentDayData {
    if (currentDayInWeek < 0 || currentDayInWeek >= listDayFood.length)
      return null;
    return listDayFood[currentDayInWeek];
  }

  void onChangeDay(int newDay) {
    currentDayInWeek = newDay;
    emit(const FoodMenuSuccess());
    emit(const FoodMenuInitial());
  }

  Future<void> getTemplateDetail({bool isRefresh = false}) async {
    if (!isRefresh) emit(const FoodMenuLoading());
    final ApiResult<MenuResponse> apiResult =
        await repository.getGetUserFoodMenu();
    apiResult.when(success: (MenuResponse response) {
      if (response.listdayfood != null) {
        listDayFood = response.listdayfood!;
      }
      if (response.food != null) {
        menuResponseFood = response.food;
      }
      emit(const FoodMenuSuccess());
    }, failure: (NetworkExceptions error) {
      emit(FoodMenuFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const FoodMenuInitial());
  }

  Future<void> changeFood() async {}
}
