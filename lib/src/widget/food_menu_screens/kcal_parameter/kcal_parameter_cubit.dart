import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/user/goal_info.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/repo/user/user_client.dart';

import 'kcal_parameter.dart';

class KcalParameterCubit extends Cubit<KcalParameterState> {
  KcalParameterCubit(this.repository) : super(InitialKcalParameterState());

  final AppRepository repository;
  CreateMenuRequest createMenuRequest = CreateMenuRequest.emptyRequest();

  bool get isNoSubMeal =>
      createMenuRequest.includeBreakfast != true &&
      createMenuRequest.includeLunch != true &&
      createMenuRequest.includeDinner != true;

  void onCheckedNoSubMeal() {
    emit(const KcalParameterLoading());
    createMenuRequest =
        CreateMenuRequest.emptyRequest().copyWith(kcal: createMenuRequest.kcal);
    emit(
      InitialKcalParameterState(),
    );
  }

  void refresh() {
    emit(const KcalParameterSuccess());
    emit(InitialKcalParameterState());
  }

  Future<void> getUserTarget() async {
    await Future.delayed(Duration.zero);
    emit(const KcalParameterLoading());
    try {
      final GoalInfoModel? data = await UserClient().fetchGoalInfo();
      createMenuRequest.includeBreakfast = data?.includeBreakfast ?? false;
      createMenuRequest.includeLunch = data?.includeLunch ?? false;
      createMenuRequest.includeDinner = data?.includeDinner ?? false;
      emit(KcalParameterKcalChanged(data?.dailyEnergyGoal?.toInt()));
    } catch (error) {
      emit(KcalParameterFailure(error.toString()));
    }
    emit(InitialKcalParameterState());
  }
}
