import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import 'detail_package.dart';

class DetailPackageCubit extends Cubit<DetailPackageState> {
  final AppRepository appRepository;
  DetailPackageData? data;
  int selectedPrice = 1;
  int selectedStory = 0;
  int selectedCourse = 0;
  int? selectedIndex;

  DetailPackageCubit(this.appRepository, this.data)
      : super(DetailPackageInitial());

  void getDetailPackage() async {
    emit(DetailPackageLoading());
    if (data?.code == null) {
      emit(DetailPackageInitial());
      return;
    }
    ApiResult<DetailPackageResponse> apiResult =
        await appRepository.getDetailPackage(data?.code ?? Const.PRO);
    apiResult.when(success: (DetailPackageResponse response) {
      if (response.data != null) data = response.data!;
      emit(DetailPackageSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DetailPackageFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void selectOption(int index) {
    emit(DetailPackageLoading());
    selectedIndex = index;
    emit(DetailPackageInitial());
  }

  void selectPrice(int index) {
    emit(DetailPackageLoading());
    selectedPrice = index;
    emit(DetailPackageInitial());
  }

  void selectStory(int index) {
    emit(DetailPackageLoading());
    selectedStory = index;
    emit(DetailPackageInitial());
  }

  void selectCourse(int index) {
    emit(DetailPackageLoading());
    selectedCourse = index;
    emit(DetailPackageInitial());
  }
}
