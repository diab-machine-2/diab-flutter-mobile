import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/food_change_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';

import '../../../repo/home/home_client.dart';
import '../../my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'daily_nutrition.dart';

class DailyNutritionCubit extends Cubit<DailyNutritionState> {
  DailyNutritionCubit(this.repository, this.goalId)
      : super(const DailyNutritionInitial());

  final AppRepository repository;
  final FoodClient foodClient = FoodClient();
  final HbA1CClient hbA1CClient = HbA1CClient();

  UserInfoResponseData? userInfo;

  bool showDetail = false;

  ShortGuiModel? des;

  TimeFrameModel? selectedTimeFrame;
  DateTime selectedDate = DateTime.now();

  List<FoodModel> selectedFoods = [];
  List<FoodModel> foodSuggestByMenu = [];

  FoodInputModel? model;

  List<String?> removeIDs = [];

  List<dynamic> files = [];

  String totalKcalText = '';

  String notes = '';

  double totalKcal = 0;

  double? totalKcalInFoodMenu;

  bool addTotalCalo = false;

  String? goalId;

  String otherFoodId = '7e8c6d8e-5d34-4c86-b15e-7ffe2e156999';

  List<MenuResponseListdayfoodTimeGroupsDefaultFood?> listFoodMenu = [];

  bool get isBasicUser {
    // final String packageCode = userInfo?.packageCode ?? '';
    // return packageCode.isEmpty || packageCode == Const.BASIC;
    return false;
  }

  bool get showFoodFromMenuTitle {
    if (selectedFoods.isEmpty) return false;
    if (selectedFoods.length != foodSuggestByMenu.length) return false;
    final List<FoodModel> tmp = List<FoodModel>.from(selectedFoods);
    int i = 0;
    while (tmp.isNotEmpty && i < 100) {
      i++;
      if (isContain(tmp.last, foodSuggestByMenu)) {
        tmp.removeLast();
      } else {
        return false;
      }
    }
    return true;
  }

  bool isContain(FoodModel food, List<FoodModel> listFood) {
    for (final model in listFood) {
      if (food.id != null &&
          food.id == model.id &&
          food.portion == model.portion) {
        return true;
      }
    }
    return false;
  }

  double get totalKcalNumber => addTotalCalo ? parsedTotalKcal : totalKcal;

  void onToggleButton(bool newState) {
    totalKcal = 0;
    selectedFoods = [];
    addTotalCalo = newState;
    refresh();
  }

  Future<void> getInitialData({String? type, String? id}) async {
    if (type == null || type.isEmpty) return;
    // await getCurrentUserInfo();
    if (type == 'update') {
      loadDetail(id);
    } else {
      loadTimeFrame();
    }
    loadDescription();
  }

  void refresh() {
    emit(const DailyNutritionSuccess());
    emit(const DailyNutritionInitial());
  }

  void showDetailToggle() {
    showDetail = !showDetail;
    refresh();
  }

  void removeFood(int index) {
    if (files[index] is XFile) {
      files.removeAt(index);
    } else {
      removeIDs.add(files[index].id);
      files.removeAt(index);
    }
    calculatorCalo();
    refresh();
  }

  Future<void> loadTimeFrame() async {
    emit(const DailyNutritionLoading());
    final List<TimeFrameModel> timeFrames = await foodClient.fetchFoodTimeFrame(
        time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.isEmpty ? null : timeFrames.first;
    await getSuggestFood();
    calculatorCalo();
    refresh();
  }

  Future<void> loadDetail(String? id) async {
    emit(const DailyNutritionLoading());
    model = await FoodClient().fetchDetailInput(id);
    selectedDate = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
    notes = model!.note ?? '';
    files.addAll(model!.images);
    selectedTimeFrame =
        TimeFrameModel(id: model!.mealId, code: '', name: model!.mealText);
    final int index =
        model!.foods.indexWhere((element) => element.id == otherFoodId);
    if (index == -1) {
      selectedFoods = model!.foods;
    } else {
      addTotalCalo = true;
      totalKcalText = ((model!.foods[index].portion ?? 1) *
              (model!.foods[index].calorie ?? 1))
          .round()
          .toString();
    }
    calculatorCalo();
    emit(const DailyNutritionFillData());
    emit(const DailyNutritionInitial());
  }

  Future<void> getCurrentUserInfo() async {
    emit(const DailyNutritionLoading());
    final ApiResult<UserInfoResponse> apiResult =
        await repository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      userInfo = response.data;
      emit(const DailyNutritionSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DailyNutritionFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const DailyNutritionInitial());
  }

  Future<void> getSuggestFood() async {
    if (timeCode == null || isBasicUser && selectedDate.weekday > 2) {
      selectedFoods = [];
      foodSuggestByMenu = [];
      totalKcalInFoodMenu = null;
      refresh();
      return;
    }
    emit(const DailyNutritionLoading());
    final ApiResult<MenuResponse> apiResult =
        await repository.getUserFoodMenu();
    apiResult.when(success: (MenuResponse response) {
      if (response.listdayfood == null || response.food == null) {
        selectedFoods = [];
        foodSuggestByMenu = [];
        totalKcalInFoodMenu = null;
      } else {
        selectedFoods = response.foodListInTime(
              time: selectedDate,
              timeCode: timeCode ?? 1,
            ) ??
            [];

        for (var dayFood in response.listdayfood ?? []) {
          for (var timeGroup in dayFood.timeGroups ?? []) {
            for (var defaultFood in timeGroup.defaultFood ?? []) {
              listFoodMenu.add(defaultFood);
            }
          }
        }
        foodSuggestByMenu = List<FoodModel>.from(selectedFoods);
        totalKcalInFoodMenu = getTotalKcalFromListFood(selectedFoods);
      }
      calculatorCalo();
      emit(const DailyNutritionSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DailyNutritionFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const DailyNutritionInitial());
  }

  double getTotalKcalFromListFood(List<FoodModel> foods) {
    double total = 0;
    for (final FoodModel food in foods) {
      total += (food.calorie ?? 0) * (food.portion ?? 0);
    }
    return total;
  }

  double get parsedTotalKcal => double.tryParse(totalKcalText) ?? 0;

  Future<void> changeFood({
    required FoodModel newFoodModel,
  }) async {
    await Future.delayed(Duration.zero);
    emit(const DailyNutritionLoading());
    final FoodChangeRequest request = FoodChangeRequest(
      id: newFoodModel.mealId,
      foodId: newFoodModel.id,
      portion: newFoodModel.portion,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.changeFood(request);
    apiResult.when(success: (CommonResponse response) async {
      // Update the food in selectedFoods before calculating calories
      final int index = selectedFoods.indexWhere(
        (food) =>
            food.id == newFoodModel.id && food.mealId == newFoodModel.mealId,
      );
      if (index != -1) {
        selectedFoods[index] = newFoodModel;
      }
      calculatorCalo();
      emit(const DailyNutritionSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DailyNutritionFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const DailyNutritionInitial());
  }

  int? get timeCode {
    if (selectedTimeFrame?.name == Const.BREAKFAST) return 1;
    if (selectedTimeFrame?.name == Const.LUNCH) return 2;
    if (selectedTimeFrame?.name == Const.DINNER) return 3;
    if (selectedTimeFrame?.name == Const.SUBMEAL) return 0;
    return null;
  }

  void calculatorCalo() {
    if (addTotalCalo) {
      totalKcal = parsedTotalKcal;
    }
    totalKcal = 0;
    for (final food in selectedFoods) {
      totalKcal += food.calorie! * (food.portion ?? 0);
    }
    refresh();
  }

  Future<void> loadDescription() async {
    des = await hbA1CClient.fetchShortGuide(4);
    refresh();
  }

  bool inputValid() {
    if (addTotalCalo) {
      if (totalKcalText.isEmpty) {
        emit(const DailyNutritionFailure('Bạn chưa nhập tổng calo'));
        return false;
      }
      if (parsedTotalKcal <= 0) {
        emit(const DailyNutritionFailure('Tổng số calo phải lớn hơn 0'));
        return false;
      }
      if (notes.isEmpty) {
        emit(const DailyNutritionFailure('Bạn chưa nhập ghi chú'));
        return false;
      }
    } else {
      if (selectedDate == null) {
        emit(DailyNutritionFailure(R.string.ban_chua_nhap_thoi_gian.tr()));
        return false;
      }
      if (selectedTimeFrame == null) {
        emit(DailyNutritionFailure(R.string.ban_chua_chon_khung_gio.tr()));
        return false;
      }
      if (selectedFoods.isEmpty) {
        emit(DailyNutritionFailure(R.string.ban_chua_chon_mon_an.tr()));
        return false;
      }
    }
    return true;
  }

  submitData() async {
    if (!inputValid()) return;
    emit(const DailyNutritionLoading());
    try {
      final List<String> paths = [];
      for (final file in files) {
        paths.add(file.path);
      }
      final result = await FoodClient().postIndexFood(
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame?.id,
          notes,
          addTotalCalo
              ? [FoodModel(id: otherFoodId, portion: parsedTotalKcal)]
              : selectedFoods,
          paths);
      if (result == true) {
        //  if(goalId != null && goalId?.isNotEmpty == true){
        await HomeClient().completeSmartGoal(
            selectedDate, goalId ?? '', 1, ScheduleType.food.typeIndex);
        //  }
        Observable.instance.notifyObservers([], notifyName: "food_change_data");

        // Set flag to show phone validation after successful nutrition input
        PhoneValidationManager.setShouldShowPhoneValidation();

        emit(const DailyNutritionSubmitSuccess());
      }
      emit(const DailyNutritionSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(DailyNutritionFailure(e.toString()));
      } else {
        emit(DailyNutritionFailure(e.toString()));
      }
    }
    emit(const DailyNutritionInitial());
  }

  editData(String? id) async {
    if (!inputValid()) return;
    emit(const DailyNutritionLoading());
    try {
      final List<String> paths = [];
      for (final file in files) {
        if (file is PickedFile || file is XFile) {
          paths.add(file.path);
        }
      }
      // Swap portion and quantity for all selectedFoods
      final List<FoodModel> swappedFoods = selectedFoods.map((food) {
        return food.copyWith(
          portion: food.quantity,
          quantity: food.portion,
        );
      }).toList();
      final bool result = await FoodClient().updateIndexFood(
          id,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame!.id,
          notes,
          addTotalCalo
              ? [FoodModel(id: otherFoodId, portion: parsedTotalKcal)]
              : swappedFoods,
          removeIDs,
          paths);
      if (result == true) {
        Observable.instance.notifyObservers([], notifyName: "food_change_data");
        emit(const DailyNutritionSubmitSuccess());
      }

      emit(const DailyNutritionSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(DailyNutritionFailure(e.toString()));
      } else {
        emit(DailyNutritionFailure(e.toString()));
      }
    }
    emit(const DailyNutritionInitial());
  }

  deleteData(String? id) async {
    try {
      emit(const DailyNutritionLoading());
      final result = await FoodClient().deleteInputFood(id);
      if (result == true) {
        emit(DailyNutritionFailure(R.string.xoa_thanh_cong.tr()));
        // Clear saved nutrition data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('latest_nutrition_percent');
        await prefs.remove('latest_nutrition_colors');
        // Set kcal to 0 (not remove) so home page overrides stale backend API value
        final todayKey = DateTime.now().toIso8601String().substring(0, 10);
        await prefs.setDouble('latest_meal_kcal', 0);
        await prefs.setString('latest_meal_kcal_date', todayKey);
        await prefs.remove('latest_meal_score');
        await prefs.remove('latest_meal_range');
        await prefs.remove('latest_meal_score_suggestion');
        Observable.instance.notifyObservers([], notifyName: "food_change_data");
        emit(const DailyNutritionSubmitSuccess());
      }

      emit(const DailyNutritionSuccess());
    } catch (e, _) {
      if (e is Error) {
        emit(DailyNutritionFailure(e.toString()));
      } else {
        emit(DailyNutritionFailure(e.toString()));
      }
    }
    emit(const DailyNutritionInitial());
  }
}
