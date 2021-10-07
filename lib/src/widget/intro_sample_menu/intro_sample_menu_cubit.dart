import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'intro_sample_menu.dart';

class IntroSampleMenuCubit extends Cubit<IntroSampleMenuState> {

  final AppRepository appRepository;
  final bool isBasic = false;
  int? selectedIndex;

  IntroSampleMenuCubit(this.appRepository) : super(IntroSampleMenuInitial());

  void selectOption(int index) {
    emit(IntroSampleMenuLoading());
    selectedIndex = index;
    emit(IntroSampleMenuInitial());
  }

}
