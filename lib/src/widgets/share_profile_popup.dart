import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/mark_share_request.dart';
import 'package:medical/src/model/request/update_shared_profile_request.dart';
import 'package:medical/src/model/response/update_shared_profile_response.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/shared_profile/shared_profile.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../app.dart';
import '../model/request/has_shared_profile_request.dart';
import '../model/response/common_response.dart';
import '../utils/navigation_util.dart';

class ShareProfilePopup {
  ShareProfilePopup._privateConstructor() {
    appRepository = AppRepository();
  }

  static final ShareProfilePopup instance = ShareProfilePopup._privateConstructor();

  late final AppRepository appRepository;
  final user = AppSettings.userInfo;

  Future<void> onHasSharedCode({
    BuildContext? context,
    final bool requestFromDoctor = false,
    required final String code,
  }) async {
    if(code.isEmpty) return;
    bool isCancel = false;
    final BuildContext currentContext = context ?? navigatorKey.currentState!.context;
    
    final bool hasShareProfile = await _hasShareProfile(currentContext, code: code);
    final UserInfoReferralCodeResponse? userInfo = await _getSharedProfile(currentContext, code: code);
    if (userInfo?.isUserExists != true) {
      Message.showToastMessage(currentContext, R.string.qr_not_available.tr());
      return;
    }

    if(hasShareProfile == true){
      Message.showToastMessage(
          currentContext, R.string.has_share_doctor_profile.tr(args: [userInfo?.data?.fullName ?? '']));
      return;
    }

    if (userInfo?.notValidPosition == true) {
      Message.showToastMessage(
          currentContext, R.string.unable_share_doctor_profile.tr(args: [userInfo?.data?.fullName ?? '']));
      return;
    }
    showPopup(currentContext,
        image: R.drawable.img_sharing_profile,
        title: requestFromDoctor
            ? R.string.doctor_request_share_profile.tr(args: [userInfo?.data?.fullName ?? ''])
            : R.string.share_profile_for_doctor.tr(args: [userInfo?.data?.fullName ?? '']),
        description: R.string.share_profile_description.tr(), 
        onTapCancel: () async {
          if(!isCancel){
            await markIsShare();
            NavigationUtil.pop(currentContext);
            isCancel = true;
          }
        }, onTapYes: () async {
          final bool sharingSuccessed = await _shareProfile(currentContext, code: code);
          if (!sharingSuccessed) return;
          await markIsShare();
          NavigationUtil.pop(currentContext);
          showPopup(currentContext,
              image: R.drawable.img_survey_completed,
              title: R.string.share_profile_success.tr(),
              description: R.string.share_profile_success_description.tr(args: [userInfo?.data?.fullName ?? '']),
              onTapYes: () {
            NavigationUtil.pop(currentContext, result: true);
          }, afterShow: () {
            NavigationUtil.navigatePage(currentContext, const SharedProfilePage());
          });
        },
      );
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
          if(onTapCancel != null){
            onTapCancel();
          } else {
            NavigationUtil.pop(context);
          }
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              if(onTapCancel != null){
                                onTapCancel();
                              } else {
                                NavigationUtil.pop(context);
                              }
                            },
                            child: Image.asset(R.drawable.ic_close, width: 28, height: 28),
                          ),
                        ],
                      ),
                      Image.asset(image),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
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
                          child: ButtonWidget(title: R.string.show_shared_list.tr(), textSize: 14, onPressed: onTapYes),
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

  Future<UserInfoReferralCodeResponse?> _getSharedProfile(BuildContext context, {String? code}) async {
    BotToast.showLoading();
    UserInfoReferralCodeResponse? data;
    final ApiResult<UserInfoReferralCodeResponse> apiResult = await appRepository.getUserFromReferralCode(code ?? '');
    apiResult.when(success: (UserInfoReferralCodeResponse response) {
      data = response;
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(context, NetworkExceptions.getErrorMessage(error));
    });
    BotToast.closeAllLoading();
    return data;
  }

  Future<void> markIsShare() async {
  //  BotToast.showLoading();
    MarkShareRequest markShareRequest = MarkShareRequest(patientId: user?.id ?? '', isShare: false);
    final ApiResult<CommonResponse> apiResult = await appRepository.markIsShare(markShareRequest);
    apiResult.when(success: (CommonResponse response) {
    }, failure: (NetworkExceptions error) {
    });
  //  BotToast.closeAllLoading();
  }

  Future<bool> _shareProfile(BuildContext context, {String? code}) async {
    BotToast.showLoading();
    bool sharingSuccessed = false;
    final UpdateSharedProfileRequest request = UpdateSharedProfileRequest(
      referalCode: code,
      referalCodeType: 3,
    );
    final ApiResult<UpdateSharedProfileResponse> apiResult = await appRepository.updateSharedProfile(request);
    apiResult.when(success: (UpdateSharedProfileResponse response) {
      sharingSuccessed = true;
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(context, error.toString());
    });
    BotToast.closeAllLoading();
    return sharingSuccessed;
  }

  Future<bool> _hasShareProfile(BuildContext context, {String? code}) async {
    BotToast.showLoading();
    bool sharingSuccessed = false;
    final ApiResult<UpdateSharedProfileResponse> apiResult = await appRepository.hasSharedProfile(code ?? "");
    apiResult.when(success: (UpdateSharedProfileResponse response) {
      sharingSuccessed = response.data ?? false;
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(context, error.toString());
    });
    BotToast.closeAllLoading();
    return sharingSuccessed;
  }
}
