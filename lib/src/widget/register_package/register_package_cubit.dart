import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'register_package.dart';

class RegisterPackageCubit extends Cubit<RegisterPackageState> {

  final AppRepository appRepository;
  int selectedIndex = 0;

  RegisterPackageCubit(this.appRepository) : super(RegisterPackageInitial());

  void selectOption(int index) {
    emit(RegisterPackageLoading());
    selectedIndex = index;
    emit(RegisterPackageInitial());
  }

}
