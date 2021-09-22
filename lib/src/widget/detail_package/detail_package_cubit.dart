import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'detail_package.dart';

class DetailPackageCubit extends Cubit<DetailPackageState> {

  final AppRepository appRepository;
  int? selectedIndex;

  DetailPackageCubit(this.appRepository) : super(DetailPackageInitial());

  void selectOption(int index) {
    emit(DetailPackageLoading());
    selectedIndex = index;
    emit(DetailPackageLoading());
  }

}
