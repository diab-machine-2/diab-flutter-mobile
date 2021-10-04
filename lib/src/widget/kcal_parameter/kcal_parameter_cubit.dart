import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'kcal_parameter.dart';

class KcalParameterCubit extends Cubit<KcalParameterState> {
  final AppRepository repository;
  int selectedMeal = 0;

  KcalParameterCubit(this.repository) : super(InitialKcalParameterState());

  void selectOptionMeal(int index) {
    emit(KcalParameterLoading());
    selectedMeal = index;
    emit(InitialKcalParameterState());
  }
}
