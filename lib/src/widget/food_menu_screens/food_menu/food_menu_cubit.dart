import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/model/request/food_change_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_menu_response.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'food_menu.dart';

class FoodMenuCubit extends Cubit<FoodMenuState> {
  FoodMenuCubit(this.repository) : super(const FoodMenuInitial());

  final AppRepository repository;

  MenuResponseFood? menuResponseFood;
  List<MenuResponseListdayfood?>? listDayFood;

  int currentDayInWeek = 0;
  UserInfoResponseData? userInfo;

  bool get isBasicUser {
    // final String packageCode = userInfo?.packageCode ?? '';
    // return packageCode.isEmpty || packageCode == Const.BASIC;
    return false;
  }

  MenuResponseListdayfood? get currentDayData {
    if (currentDayInWeek < 0 || currentDayInWeek >= (listDayFood?.length ?? 0))
      return null;
    return listDayFood?[currentDayInWeek];
  }

  void onChangeDay(int newDay) {
    currentDayInWeek = newDay;
    emit(const FoodMenuSuccess());
    emit(const FoodMenuInitial());
  }

  Future<void> createMenu({CreateMenuRequest? request}) async {
    if (request != null) {
      emit(const FoodMenuLoading());
      final ApiResult<CreateMenuResponse> apiResult =
          await repository.createMenu(request);
      apiResult.when(success: (CreateMenuResponse response) async {
        if (response.data == null) {
          listDayFood = [];
        } else {
          currentDayInWeek = 0;
        }
        Observable.instance
          .notifyObservers([], notifyName: "refresh_home_activity");
        emit(const FoodMenuSuccess());
      }, failure: (NetworkExceptions error) {
        // emit(FoodMenuFailure(NetworkExceptions.getErrorMessage(error)));
      });
      emit(const FoodMenuInitial());
    }
    await getCurrentUserInfo();
    getTemplateDetail();
  }

  Future<void> getTemplateDetail({bool isRefresh = false}) async {
    if (!isRefresh) emit(const FoodMenuLoading());
    final ApiResult<MenuResponse> apiResult =
        await repository.getUserFoodMenu();
    apiResult.when(success: (MenuResponse response) {
      if (response.listdayfood == null || response.food == null) {
        listDayFood = [];
        emit(const FoodMenuEmpty());
      } else {
        response.sortListDayFood();
        listDayFood = response.listdayfood;
        menuResponseFood = response.food;
      }
      emit(const FoodMenuSuccess());
    }, failure: (NetworkExceptions error) {
      emit(FoodMenuFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const FoodMenuInitial());
  }

  Future<void> changeFood(
      {required String? foodId, required FoodModel newFoodModel}) async {
    await Future.delayed(Duration.zero);
    emit(const FoodMenuLoading());
    final FoodChangeRequest request = FoodChangeRequest(
      id: foodId,
      foodId: newFoodModel.id,
      portion: newFoodModel.portion,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.changeFood(request);
    apiResult.when(success: (CommonResponse response) async {
      getTemplateDetail();
      Observable.instance
          .notifyObservers([], notifyName: "refresh_home_activity");
      emit(const FoodMenuSuccess());
    }, failure: (NetworkExceptions error) {
      emit(FoodMenuFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const FoodMenuInitial());
  }

  Future<void> getCurrentUserInfo() async {
    emit(const FoodMenuLoading());
    final ApiResult<UserInfoResponse> apiResult =
        await repository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      userInfo = response.data;
      emit(const FoodMenuSuccess());
    }, failure: (NetworkExceptions error) {
      emit(FoodMenuFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const FoodMenuInitial());
  }
}
