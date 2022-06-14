import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/response/content_welcome_response.dart';
import '../../../../model/repository/app_repository.dart';
import '../../../../model/response/common_response.dart';
import '../../../../model/service/api_result.dart';
import '../../../../model/service/network_exceptions.dart';
import '../welcome_package_screen.dart';

class WelcomePackageScreenCubit extends Cubit<WelcomePackageScreenState> {

  final AppRepository repository;
  ContentWelcomeResponseData? content;
  UserModel? user;

  WelcomePackageScreenCubit(this.repository): super(WelcomePackageScreenInitial()) {}

  Future<void> getContentWelcome() async {
//    await Future.delayed(Duration.zero);
//    emit(WelcomePackageScreenLoading());

    user = AppSettings.userInfo;
    content = ContentWelcomeResponseData(
      accountId: user?.accountId,
      packageId: user?.packageAccount?.packageId,
      fullName: user?.fullName,
      packageName: user?.packageName,
      gender: user?.genderType,
      hotLine: AppSettings.secureModel?.hotline,
    );
    emit(const WelcomePackageScreenSuccess());

    // String accountId = AppSettings.userInfo?.accountId ?? '';
    // final ApiResult<ContentWelcomeResponse> apiResult = await repository.getContentWelcome(accountId);
    // apiResult.when(success: (ContentWelcomeResponse response) {
    //   content = response.data;
    //   emit(const WelcomePackageScreenSuccess());
    // }, failure: (NetworkExceptions error) {
    //   emit(WelcomePackageScreenFailure(NetworkExceptions.getErrorMessage(error)));
    // });
    emit(WelcomePackageScreenInitial());
  }

   Future<void> markDisplayedWelcome() async {
    await Future.delayed(Duration.zero);
    emit(WelcomePackageScreenLoading());
    // final ReadWelcomeRequest request =
    //     ReadWelcomeRequest(id: '');
    final ApiResult<CommonResponse> apiResult = await repository.markDisplayedWelcome();
    apiResult.when(success: (CommonResponse response) {
       AppSettings.isDisplayedWelcome = true;
       emit(const WelcomePackageScreenSuccess());
    }, failure: (NetworkExceptions error) {
      emit(WelcomePackageScreenFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  String getGender(int? gender){
    if(gender == 1){
      return "anh";
    } else if(gender == 2) {
      return "chị";
    } else {
      return "bạn";
    }
  }
}