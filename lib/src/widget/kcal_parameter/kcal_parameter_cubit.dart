import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';

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
    emit(KcalParameterLoading());
    createMenuRequest =
        CreateMenuRequest.emptyRequest().copyWith(kcal: createMenuRequest.kcal);
    emit(
      InitialKcalParameterState(),
    );
  }

  void refresh() {
    emit(KcalParameterLoading());
    emit(InitialKcalParameterState());
  }
}
