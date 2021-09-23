import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'welcome_service.dart';

class WelcomeServiceCubit extends Cubit<WelcomeServiceState> {

  final AppRepository appRepository;
  int selectedIndex = 0;

  WelcomeServiceCubit(this.appRepository) : super(WelcomeServiceInitial());

  void selectOption(int index) {
    emit(WelcomeServiceLoading());
    selectedIndex = index;
    emit(WelcomeServiceInitial());
  }

}
