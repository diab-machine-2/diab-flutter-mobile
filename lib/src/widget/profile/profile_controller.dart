import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/manual.dart';
import 'package:medical/src/modal/user/secure.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/shared_profile/shared_profile.dart';
import 'package:medical/src/widgets/button_language_picker.dart';
import '../../app_setting/firebase_remote_config.dart';
import '../food_menu_screens/food_menu/food_menu_page.dart';

class ProfileController extends StatefulWidget {
  const ProfileController({this.hideAllBackButton = false});
  final bool hideAllBackButton;
  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> with Observer {
  bool isPro = true;
  SecureModel? secureModel;
  final AppRepository _appRepository = AppRepository();
  var userInfo = AppSettings.userInfo;

  Timer? _timer;
  int _count = 0;
  final int _requiredCount = 5;

  void _startTimer() {
    // delay 2s to reset count to 0
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 2), () {
      if (!mounted) return;
      _count = 0;
    });
  }

  void _launchMeeting(BuildContext context) {
    Navigator.pushNamed(context, NavigatorName.meeting_prepare);
  }

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    _loadData();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics
        .logScreenView(screenName: "profile", screenClass: "ProfileController");
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'user_info_change') {
      if (!_isDisposing) setState(() {});
    } else if (notifyName == 'logout') {
      // This line of code prevent the dispose method from NOT being called
      _logoutSignal = true;
    }
  }

  void _loadData() async {
    try {
      BotToast.showLoading();
      if (AppSettings.secureModel == null) {
        secureModel = await UserClient().fetchInfoSecure();
        AppSettings.secureModel = secureModel;
      } else {
        secureModel = AppSettings.secureModel;
      }
      // await checkPackage();
      BotToast.closeAllLoading();
      setState(() {});
    } catch (_) {
      BotToast.closeAllLoading();
    }
  }

  Future<void> checkPackage() async {
    final ApiResult<UserInfoResponse> apiResult =
        await _appRepository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      // final String packageCode = response.data?.packageCode ?? '';
      // isPro = packageCode.isNotEmpty && packageCode != Const.BASIC;
    }, failure: (NetworkExceptions error) {
      isPro = false;
    });
  }

  static bool _isDisposing = false;
  bool _logoutSignal = false;
  @override
  void dispose() async {
    // check logout case
    Observable.instance.removeObserver(this);
    if (_logoutSignal) {
      super.dispose();
      return;
    }
    if (_isDisposing) {
      return; // Already disposing, do nothing
    }
    _isDisposing = true;
    try {
      // Add your await statement, it won't be executed concurrently
      await AppSettings.syncDataFromHealthApp();
    } finally {
      _isDisposing = false;
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSettings.userInfo!;
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: R.color.color0xffB1DDDB.withOpacity(0.2),
          hideAllBackButton: widget.hideAllBackButton,
          title: Text(R.string.profile_file.tr(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark)),
          leadingIcon: IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(Icons.arrow_back, color: R.color.textDark),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            ButtonLanguagePicker(screenName: 'profile'),
          ],
        ),
        body: Container(
            color: R.color.color0xffB1DDDB.withOpacity(0.2),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ListView(
                children: [
                  Row(children: [
                    Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            color: R.color.mainColor,
                            borderRadius: BorderRadius.circular(52)),
                        child: user.imageUrl!.url == null
                            ? Icon(Icons.person,
                                size: 104, color: R.color.white)
                            : Image.network(
                                user.imageUrl!.url!,
                                width: 104,
                                height: 104,
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Icon(Icons.person,
                                      size: 100, color: R.color.white);
                                },
                              )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName!,
                              style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(R.string.user_id.tr(args: [user.code ?? '0']),
                                style: TextStyle(
                                    color: R.color.primaryGreyColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 8),
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                children: [
                                  AppSettings.isOwnPackage
                                      ? Image.network(
                                          AppSettings
                                              .userInfo!.ownPackage!.logo!,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return SizedBox();
                                          },
                                        )
                                      : Image.asset(
                                          isPro
                                              ? R.drawable.ic_pro
                                              : R.drawable.ic_crown_green,
                                          width: 20,
                                          height: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AutoSizeText(
                                        (userInfo?.packageName != null &&
                                                userInfo!
                                                    .packageName!.isNotEmpty)
                                            ? userInfo!.packageName!
                                            : R.string.thanh_vien_co_ban.tr(),
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                  )
                                ],
                              ),
                            )
                          ]),
                    ),
                  ]),
                  //Buttons
                  const SizedBox(height: 19),
                  Row(children: [
                    Expanded(
                      child: buildItem(
                          color: R.color.color0xffD3EFEE,
                          title: R.string.blood_sugar_schedule_single_line.tr(),
                          image: R.drawable.ic_blood_sugar_testing_schedule,
                          onTap: () async {
                            await TrackingManager.logEvent(
                              name: 'cta_button_clicked',
                              parameters: {
                                "screen_name": 'profile',
                                'cta_button_name':
                                    'cta_profile_glycemic_schedule',
                              },
                            );
                            Navigator.pushNamed(
                                context, NavigatorName.schedule_glucose);
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildItem(
                          color: R.color.orange_6,
                          title: R.string.goal_setting.tr(),
                          image: R.drawable.ic_set_goal,
                          onTap: () async {
                            await TrackingManager.logEvent(
                              name: 'cta_button_clicked',
                              parameters: {
                                "screen_name": 'profile',
                                'cta_button_name': 'cta_profile_set_target',
                              },
                            );
                            Navigator.pushNamed(
                                context, NavigatorName.goal_setting);
                          }),
                    )
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: buildItem(
                          isShow: isPro,
                          color: R.color.color0xffFCF8DA,
                          title: R.string.remind.tr(),
                          image: R.drawable.ic_remind,
                          onTap: () async {
                            await TrackingManager.logEvent(
                              name: 'cta_button_clicked',
                              parameters: {
                                "screen_name": 'profile',
                                'cta_button_name': 'cta_profile_remind',
                              },
                            );
                            Navigator.pushNamed(
                                context, NavigatorName.reminder);
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildItem(
                          isShow: isPro,
                          color: R.color.color0xffD3EFEE,
                          title: R.string.food_menu.tr(),
                          image: R.drawable.ic_food_menu,
                          onTap: () async {
                            // if(userInfo?.ownPackage == null) {
                            //   NavigationUtil.showUpdateRequirePopup(context: context, title: R.string.food_menu.tr());
                            //   return;
                            // }
                            await TrackingManager.logEvent(
                              name: 'cta_button_clicked',
                              parameters: {
                                "screen_name": 'profile',
                                'cta_button_name': 'cta_profile_sample_menu',
                              },
                            );
                            NavigationUtil.navigatePage(
                                context, const FoodMenuPage());
                          }),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // buildItem(
                  //     isRow: true,
                  //     color: R.color.color0xffD3EFEE,
                  //     title: R.string.my_package.tr(),
                  //     image: R.drawable.ic_my_package,
                  //     onTap: () {
                  //       NavigationUtil.navigatePage(context, MyPackagePage());
                  //     }),
                  //const SizedBox(height: 16),
                  buildAction(
                      R.string.profile_information.tr(), R.drawable.ic_user, 0),
                  buildAction(R.string.personal_schedule_single_line.tr(),
                      R.icons.ic_device, 9),
                  buildAction(R.string.share_app.tr(), R.drawable.ic_share, 6),
                  buildAction(R.string.shared_profile_list.tr(),
                      R.drawable.ic_share, 1),
                  buildAction(R.string.connect_device.tr(),
                      R.drawable.ic_heart_connect, 7),
                  buildAction(
                      R.string.user_manual.tr(), R.drawable.ic_question, 2),
                  buildAction(R.string.information_security.tr(),
                      R.drawable.ic_security, 3),
                  // buildAction(R.string.contact_diab.tr(), R.drawable.ic_contact, 4),
                  buildAction(
                      R.string.password.tr(), R.drawable.ic_password, 5),
                  buildAction(R.string.your_voucher.tr(), R.icons.ic_gift, 8),
                  buildAction(R.string.exchange_return_policy.tr(), R.icons.ic_policy, 10),
                  Builder(builder: (ctx) {
                    Widget child = Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'App version: ${AppSettings.version} (${AppSettings.buildNumber})',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.accentColor),
                      ),
                    );
                    if (FirebaseRemoteSetting.instance.appDeveloperMode) {
                      child = GestureDetector(
                        onTap: () {
                          _count++;
                          if (_count >= _requiredCount) {
                            _count = 0;
                            _launchMeeting(ctx);
                          } else {
                            _startTimer();
                          }
                        },
                        child: child,
                      );
                    }
                    return child;
                  }),
                ],
              ),
            )));
  }

  Widget buildItem({
    bool isShow = true,
    bool isRow = false,
    required Color color,
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    final Widget textWidget = Text(
      title,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: R.color.textDark),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return Visibility(
      visible: isShow,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: isRow
              ? const EdgeInsets.symmetric(vertical: 7, horizontal: 12)
              : const EdgeInsets.symmetric(vertical: 14),
          child: isRow
              ? Row(
                  children: [
                    Image.asset(image, width: 35, height: 35),
                    const SizedBox(width: 12),
                    textWidget,
                  ],
                )
              : Column(
                  children: [
                    Image.asset(image, width: 35, height: 35),
                    const SizedBox(height: 12),
                    textWidget,
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildAction(String title, String icon, int index) {
    bool isSvgIcon = icon.split('.').last == "svg";
    return GestureDetector(
      onTap: () async {
        await TrackingManager.logEvent(
          name: 'component_clicked',
          parameters: {
            "screen_name": 'profile',
            'component_name': 'cta_profile_function',
            'object_title': title,
          },
        );
        if (index == 0) {
          final String phoneNumber = AppSettings.userInfo?.phoneNumber ?? '';
          if (phoneNumber.isEmpty || phoneNumber.contains('User')) {
            // showPopupUpdatePhone();
            Navigator.pushNamed(context, NavigatorName.profile_info);
          } else {
            Navigator.pushNamed(context, NavigatorName.profile_info);
          }
        } else if (index == 1) {
          NavigationUtil.navigatePage(context, const SharedProfilePage());
        } else if (index == 2) {
          Navigator.pushNamed(context, NavigatorName.manual);
        } else if (index == 3) {
          Navigator.pushNamed(context, NavigatorName.manual_detail, arguments: {
            'manual': ManualModel(
                id: '',
                question: R.string.information_security.tr(),
                answer: secureModel!.security)
          });
        } else if (index == 4) {
          Navigator.pushNamed(context, NavigatorName.contact,
              arguments: {'contact': secureModel});
        } else if (index == 5) {
          Navigator.pushNamed(context, NavigatorName.change_password);
        } else if (index == 6) {
          String? shareLink = BranchioLinkConfig.instance.shareLink;
          if (shareLink != null) {
            AppShare.instance.userReferralCode(context, shareLink);
          }
        } else if (index == 7) {
          Navigator.pushNamed(context, NavigatorName.connect_device_app);
        } else if (index == 8) {
          Navigator.pushNamed(context, NavigatorName.voucher_list);
        } else if (index == 9) {
          Navigator.pushNamed(context, NavigatorName.schedule_activity);
        } else if (index == 10) {
          Navigator.pushNamed(
              context, NavigatorName.cancellation_refund_policy);
        }
      },
      child: Container(
          color: R.color.transparent,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  isSvgIcon
                      ? SvgPicture.asset(
                          icon,
                          width: 20,
                          height: 20,
                          color: R.color.accentColor,
                        )
                      : Image.asset(icon, width: 20, height: 20),
                  const SizedBox(width: 16),
                  Text(title, style: const TextStyle(fontSize: 16))
                ]),
                Icon(Icons.arrow_forward_ios,
                    color: R.color.mainColor, size: 16)
              ]),
              const SizedBox(height: 20),
              Container(height: 1, color: R.color.grey.withOpacity(0.2))
            ],
          )),
    );
  }

  showPopupUpdatePhone() {
    FocusScope.of(context).unfocus();
    final width = MediaQuery.of(context).size.width;
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo?.secondPhoneNumber ?? '';
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.update_phone_number.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 54,
                    width: width - 36,
                    child: TextField(
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        minLines: 1,
                        maxLines: 1,
                        obscureText: false,
                        decoration: InputDecoration(
                          fillColor: R.color.textDark,
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: R.color.grayComponentBorder, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: R.color.mainColor, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.only(
                              top: 0, left: 16, right: 16),
                          hintText: R.string.nhap_so_dien_thoai.tr(),
                        ),
                        onChanged: (value) {})),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, NavigatorName.profile_info);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final phone = textEditingController.text;
                            if (phone.isEmpty) {
                              Message.showToastMessage(context,
                                  R.string.ban_chua_nhap_so_dien_thoai.tr());
                              return;
                            } else {
                              updatePhone(phone);
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.save.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  updatePhone(String phone) async {
    try {
      BotToast.showLoading();
      await LoginClient().changePhoneNumber(phone);
      await UserClient().fetchUser();
      Navigator.pop(context);
      Navigator.pushNamed(context, NavigatorName.profile_info);
      BotToast.closeAllLoading();
    } catch (error) {
      BotToast.closeAllLoading();
      if (error is Error) {
        Message.showToastMessage(context, error.message);
      } else {
        Message.showToastMessage(context, error.toString());
      }
    }
  }
}
