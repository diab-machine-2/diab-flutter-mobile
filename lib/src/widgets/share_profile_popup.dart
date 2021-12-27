import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_shared_profile_request.dart';
import 'package:medical/src/model/response/update_shared_profile_response.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/shared_profile/shared_profile.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../app.dart';
import '../utils/navigation_util.dart';

class ShareProfilePopup {
  ShareProfilePopup._privateConstructor() {
    appRepository = AppRepository();
  }

  static final ShareProfilePopup instance =
      ShareProfilePopup._privateConstructor();

  late final AppRepository appRepository;

  Future<void> onHasSharedCode({
    BuildContext? context,
    final bool requestFromDoctor = false,
    required final String code,
  }) async {
    final BuildContext currentContext =
        context ?? navigatorKey.currentState!.context;
    final UserInfoReferralCodeResponse? userInfo =
        await _getSharedProfile(currentContext, code: code);
    if (userInfo?.isUserExists != true || userInfo?.notValidPosition == true)
      return;
    showPopup(currentContext,
        image: R.drawable.img_sharing_profile,
        title: requestFromDoctor
            ? R.string.doctor_request_share_profile
                .tr(args: [userInfo?.data?.fullName ?? ''])
            : R.string.share_profile_for_doctor.tr(args: [
                userInfo?.data?.fullName ?? '',
                userInfo?.data?.nameOfAgency ?? ''
              ]),
        description: R.string.share_profile_description.tr(), onTapCancel: () {
      NavigationUtil.pop(currentContext);
    }, onTapYes: () async {
      final bool sharingSuccessed =
          await _shareProfile(currentContext, code: code);
      if (!sharingSuccessed) return;
      NavigationUtil.pop(currentContext);
      showPopup(currentContext,
          image: R.drawable.img_survey_completed,
          title: R.string.share_profile_success.tr(),
          description: R.string.share_profile_success_description
              .tr(args: [userInfo?.data?.fullName ?? '']), onTapYes: () {
        NavigationUtil.pop(currentContext, result: true);
      }, afterShow: () {
        NavigationUtil.navigatePage(currentContext, const SharedProfilePage());
      });
    });
  }

  static Future<void> showPopup(
    context, {
    required String image,
    required String title,
    required String description,
    VoidCallback? onTapCancel,
    required VoidCallback onTapYes,
    VoidCallback? afterShow,
  }) async {
    final result = await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.white,
                      R.color.main_6,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(image),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 20),
                      if (onTapCancel != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 130.w,
                              height: 43,
                              child: ButtonWidget(
                                  title: R.string.later.tr(),
                                  textSize: 14,
                                  backgroundColor: R.color.grayBorder,
                                  textColor: R.color.textDark,
                                  onPressed: onTapCancel),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 130.w,
                              height: 43,
                              child: ButtonWidget(
                                title: R.string.confirm.tr(),
                                textSize: 14,
                                onPressed: onTapYes,
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: 245.w,
                          height: 43,
                          child: ButtonWidget(
                              title: R.string.show_shared_list.tr(),
                              textSize: 14,
                              onPressed: onTapYes),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (result is bool && result && afterShow != null) {
      afterShow.call();
    }
  }

  Future<UserInfoReferralCodeResponse?> _getSharedProfile(BuildContext context,
      {String? code}) async {
    BotToast.showLoading();
    UserInfoReferralCodeResponse? data;
    final ApiResult<UserInfoReferralCodeResponse> apiResult =
        await appRepository.getUserFromReferralCode(code ?? '');
    apiResult.when(success: (UserInfoReferralCodeResponse response) {
      data = response;
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(
          context, NetworkExceptions.getErrorMessage(error));
    });
    BotToast.closeAllLoading();
    return data;
  }

  Future<bool> _shareProfile(BuildContext context, {String? code}) async {
    BotToast.showLoading();
    bool sharingSuccessed = false;
    final UpdateSharedProfileRequest request = UpdateSharedProfileRequest(
      referalCode: code,
      referalCodeType: 3,
    );
    final ApiResult<UpdateSharedProfileResponse> apiResult =
        await appRepository.updateSharedProfile(request);
    apiResult.when(success: (UpdateSharedProfileResponse response) {
      sharingSuccessed = true;
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(context, error.toString());
    });
    BotToast.closeAllLoading();
    return sharingSuccessed;
  }
}
