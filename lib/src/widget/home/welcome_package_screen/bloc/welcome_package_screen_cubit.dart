import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/model/response/content_welcome_response.dart';
import 'package:medical/src/model/response/get_customer_receives_user_response.dart';
import 'package:medical/src/utils/utils.dart';
import '../../../../model/repository/app_repository.dart';
import '../../../../model/response/common_response.dart';
import '../../../../model/service/api_result.dart';
import '../../../../model/service/network_exceptions.dart';
import '../welcome_package_screen.dart';

class WelcomePackageScreenCubit extends Cubit<WelcomePackageScreenState> {
  final AppRepository repository;
  ContentWelcomeResponseData? content;
  UserModel? user;

  WelcomePackageScreenCubit(this.repository)
      : super(WelcomePackageScreenInitial());

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
    final ApiResult<CommonResponse> apiResult =
        await repository.markDisplayedWelcome();
    apiResult.when(success: (CommonResponse response) {
      // AppSettings.isDisplayedWelcome = true;
      emit(const WelcomePackageScreenSuccess());
    }, failure: (NetworkExceptions error) {
      // emit(WelcomePackageScreenFailure(
      //     NetworkExceptions.getErrorMessage(error)));
    });
  }


  Future<String?> getCustomerReceivesUser() async {
    await Future.delayed(Duration.zero);
    // BotToast.showLoading();
    final phoneNumber = AppSettings.userInfo?.phoneNumber ?? '';
    if (phoneNumber.isEmpty) {
      // BotToast.closeAllLoading();
      BotToast.showText(text: "Không tìm thấy thông tin người nhận");
      return null;
    }

    String? result;
    final ApiResult<GetCustomerReceivesUserResponse> apiResult =
        await repository
            .getCustomerReceivesUser(Utils.formatPhoneNumber(phoneNumber));

    apiResult.when(success: (GetCustomerReceivesUserResponse response) {
      if (response.data != null) {
        final value = response.data?.firstOrNull;
        if (value != null) {
          emit(WelcomePackageScreenSuccess());
          result = response.data?.first.zaloGroup;
        }
      }
    }, failure: (NetworkExceptions error) {
      emit(WelcomePackageScreenFailure(
          NetworkExceptions.getErrorMessage(error)));
    });

    // BotToast.closeAllLoading();
    return result;
  }

  String getGender(int? gender) {
    String appLanguage = AppPreference().appLanguage;
    if (appLanguage == "en") return "you";
    if (gender == 1) {
      return "anh";
    } else if (gender == 2) {
      return "chị";
    } else {
      return "bạn";
    }
  }
}
