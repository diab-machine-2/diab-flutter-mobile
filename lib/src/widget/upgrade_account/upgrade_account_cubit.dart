import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/send_interest_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/logger.dart';

import 'upgrade_account.dart';

class UpgradeAccountCubit extends Cubit<UpgradeAccountState> {

  final AppRepository appRepository;

  String? ownCode;

  DetailPackageData? data;
  int selectedPrice = 1;
  int selectedStory = 0;
  int selectedCourse = 0;
  int selectedAdvantage = 0;
  int? selectedIndexInterest;

  UpgradeAccountCubit(this.appRepository) : super(UpgradeAccountInitial());

  void getOwnPackageCode() async {
    ApiResult<UserInfoResponse> apiResult = await appRepository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      // ownCode = response.data?.packageCode;
    }, failure: (NetworkExceptions error) {
      logger.e(NetworkExceptions.getErrorMessage(error));
    });
  }


  void getUpgradeAccount(String code, {bool isRefresh = false}) async {
    emit(isRefresh ? UpgradeAccountInitial() : UpgradeAccountLoading());
    ApiResult<DetailPackageResponse> apiResult = await appRepository.getDetailPackage(code);
    apiResult.when(success: (DetailPackageResponse response) {
      data = response.data;
      emit(UpgradeAccountSuccess());
    }, failure: (NetworkExceptions error) {
      emit(UpgradeAccountFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void sendInterestFeedback(String? message) async {
    emit(UpgradeAccountLoading());
    SendInterestRequest request = SendInterestRequest(packageId: data?.id, type: (selectedIndexInterest ?? 0) + 1, message: message);
    ApiResult<CommonResponse> apiResult =
    await appRepository.sendInterestFeedback(request);
    apiResult.when(success: (CommonResponse response) {
      emit(SendInterestSuccess());
    }, failure: (NetworkExceptions error) {
      emit(UpgradeAccountFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void selectOptionInterest(int index) {
    emit(UpgradeAccountLoading());
    selectedIndexInterest = index;
    emit(UpgradeAccountInitial());
  }

  void selectAdvantage(int index) {
    emit(UpgradeAccountLoading());
    selectedAdvantage = index;
    emit(UpgradeAccountInitial());
  }

  void selectPrice(int index) {
    emit(UpgradeAccountLoading());
    selectedPrice = index;
    emit(UpgradeAccountInitial());
  }

  void selectStory(int index) {
    emit(UpgradeAccountLoading());
    selectedStory = index;
    emit(UpgradeAccountInitial());
  }

  void selectCourse(int index) {
    emit(UpgradeAccountLoading());
    selectedCourse = index;
    emit(UpgradeAccountInitial());
  }

}
