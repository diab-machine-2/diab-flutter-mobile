import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'congratulation.dart';

class CongratulationCubit extends Cubit<CongratulationState> {

  final AppRepository appRepository;
  int selectedIndex = 0;

  CongratulationCubit(this.appRepository) : super(CongratulationInitial());

  void selectOption(int index) {
    emit(CongratulationLoading());
    selectedIndex = index;
    emit(CongratulationInitial());
  }

}
