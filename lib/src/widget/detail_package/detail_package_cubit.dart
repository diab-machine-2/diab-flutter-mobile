import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/send_interest_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import 'detail_package.dart';

class DetailPackageCubit extends Cubit<DetailPackageState> {
  final AppRepository appRepository;
  String code;
  DetailPackageData? data;
  int selectedPrice = 1;
  int selectedStory = 0;
  int selectedCourse = 0;
  int? selectedIndexInterest;

  bool get isBoughtPro => false;

  DetailPackageCubit(this.appRepository, this.code)
      : super(DetailPackageInitial());

  void getDetailPackage() async {
    emit(DetailPackageLoading());
    ApiResult<DetailPackageResponse> apiResult =
        await appRepository.getDetailPackage(code);
    apiResult.when(success: (DetailPackageResponse response) {
      if (response.data != null) data = response.data!;
      emit(DetailPackageSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DetailPackageFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void sendInterestFeedback(String? message) async {
    emit(DetailPackageLoading());
    SendInterestRequest request = SendInterestRequest(packageId: data?.id, type: (selectedIndexInterest ?? 0) + 1, message: message);
    ApiResult<CommonResponse> apiResult =
    await appRepository.sendInterestFeedback(request);
    apiResult.when(success: (CommonResponse response) {
      emit(SendInterestSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DetailPackageFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void selectOptionInterest(int index) {
    emit(DetailPackageLoading());
    selectedIndexInterest = index;
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
