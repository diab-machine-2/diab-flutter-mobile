import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/deep_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/service/zalo_service.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_language_picker.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:package_info/package_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'widgets/social_login_section.dart';

enum _LoginZaloProgress { none, inprogress, gottoken }

class StepListController extends StatefulWidget {
  const StepListController(this.sharedCode);
  final String sharedCode;
  @override
  _StepListControllerState createState() => _StepListControllerState();
}

class _StepListControllerState extends State<StepListController>
    with Observer, WidgetsBindingObserver {
  final PageController pageController = PageController();

  var currentPage = 0;
  int _retry = 0;
  _LoginZaloProgress _loginZaloProgress = _LoginZaloProgress.none;

  String name = '';

  var data = [
    // {
    //   'name': R.string.dong_hanh_va_se_chia,
    //   'image': R.drawable.img_step1,
    //   'text': R.string.dong_hanh_va_se_chia_description,
    // },
    // {
    //   'name': R.string.hieu_de_yeu_ban_than_hon,
    //   'image': R.drawable.img_step2,
    //   'text': R.string.hieu_de_yeu_ban_than_hon_description,
    // },
    // {
    //   'name': R.string.va_khong_chi_co_ban,
    //   'image': R.drawable.img_step3,
    //   'text': R.string.va_khong_chi_co_ban_description,
    // }
    {
      'name': 'Thư viện bài học',
      'image': R.drawable.img_step1,
      'text': 'Cung cấp kiến thức bệnh lý, dinh dưỡng, vận động',
    },
    {
      'name': 'Nhật ký sức khoẻ',
      'image': R.drawable.img_step2,
      'text':
          'Theo dõi, quản lý và chia sẻ các chỉ số sức khỏe cho bác sĩ, chuyên gia',
    },
    {
      'name': 'Hỏi đáp cùng bác sĩ',
      'image': R.drawable.img_step3,
      'text':
          'Nhận sự tư vấn, hỗ trợ trực tiếp từ đội ngũ bác sĩ và Chuyên gia giàu kinh nghiệm',
    }
  ];

  Timer? _timer;

  String version = '';
  String buildNumber = '';
  String sharedCode = '';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Future.delayed(Duration(milliseconds: 500), () async {
          if (!mounted) return;
          if (_loginZaloProgress == _LoginZaloProgress.inprogress) {
            // _retry start from 0
            _retry++;
            if (_retry == 1) {
              _showRetryPopup();
            } else {
              Message.showToastMessage(
                  context, "zalo_second_failed_message".tr());
            }
          }
        });
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    WidgetsBinding.instance.addObserver(this);
    // DynamicLinkConfig.instance.getLongLink();
    // DynamicLinkConfig.instance.setUpHandleDeepLink();
    // if (widget.sharedCode != "") {
    //   Navigator.pushNamed(
    //     context,
    //     NavigatorName.register,
    //     arguments: widget.sharedCode,
    //   );
    // }

    //startTimer();
    DeepLinkConfig.setUpHandleDeepLink(onHaveLink: (code) {
      if (code?.isNotEmpty == true) {
        sharedCode = code ?? '';
        // Navigator.pushNamed(
        //   context,
        //   NavigatorName.register,
        //   arguments: code,
        // );
      }
    });
    //  getSecuredModel();
    //  getVersion();

    if (widget.sharedCode.isNotEmpty) {
      sharedCode = widget.sharedCode;
      // Navigator.pushNamed(
      //   context,
      //   NavigatorName.register,
      //   arguments: widget.sharedCode,
      // );
    }
    Future.delayed(Duration(milliseconds: 600), () async {
      FlutterNativeSplash.remove();
      checkReferralCode();
    });
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "welcome", screenClass: "StepListController");
    AppSettings.currentScreenName = 'welcome';
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      setState(() {});
    }
    if (notifyName == Const.NAVIGATE_TO_REGISTER) {
      Navigator.pushNamed(context, NavigatorName.register);
    }
  }

  void startTimer() {
    _timer = new Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (currentPage < 2) {
        currentPage += 1;
      } else {
        currentPage = 0;
      }
      pageController.animateToPage(currentPage,
          duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  checkReferralCode() async {
    final String? referalCode = DynamicLinkConfig.instance.referalCode;
    if (referalCode != null) {
      await Navigator.pushNamed(
        context,
        NavigatorName.register,
        arguments: referalCode,
      );
    }
  }

  // getSecuredModel() async {
  //   try{
  //     secureModel = await UserClient().fetchInfoSecure();
  //     await AppSettings.saveEnvironment(secureModel?.environment);
  //     AppSettings.environment = secureModel?.environment;
  //     AppSettings.secureModel = secureModel;
  //     AppClient();
  //   } catch(exception){
  //     secureModel = SecureModel(
  //       email: "lienhe@diab.com.vn",
  //       support: "Supporter",
  //       hotline: "0768 07 07 27",
  //       security: "security",
  //       environment: "staging",
  //     );
  //     AppClient();
  //   }
  // }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    // DynamicLinkConfig.instance.dispose();
    Observable.instance.removeObserver(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SpacingColumn(
                  spacing: 25.h,
                  children: [
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 290.h,
                      child: PageView.builder(
                          onPageChanged: (index) async {
                            final name = data[index]['name']!;
                            await TrackingManager.analytics.logEvent(
                                name: 'component_clicked',
                                parameters: {
                                  "screen_name": 'welcome',
                                  'object_index': index,
                                  'object_title': name,
                                  'component_name': 'slider_welcome',
                                });
                            setState(() {
                              currentPage = index;
                            });
                          },
                          controller: pageController,
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final name = data[index]['name']!;
                            final image = data[index]['image']!;
                            final text = data[index]['text']!;
                            return imageItem(context, name, image, text);
                          }),
                    ),
                    SmoothPageIndicator(
                      controller: pageController,
                      count: 3,
                      effect: ExpandingDotsEffect(
                          dotWidth: 5,
                          dotHeight: 5,
                          dotColor: Color(0xFFD3D3D3),
                          activeDotColor: R.color.mainColor),
                    ),
                    builtItemText(
                      data[currentPage]['name']!,
                      data[currentPage]['text']!,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      margin: EdgeInsets.only(bottom: 16),
                      child: SpacingColumn(
                          spacing: 15,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 52,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: GestureDetector(
                                  onTap: () => loginZalo(),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        width: 24,
                                        height: 24,
                                        R.icons.ic_zalo,
                                      ),
                                      Expanded(
                                        child: AutoSizeText(
                                          'Đăng nhập qua Zalo',
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            // Expanded(
                            //   child: GestureDetector(
                            //     onTap: () async {
                            //       await TrackingManager.analytics.logEvent(
                            //         name: 'cta_button_clicked',
                            //         parameters: {
                            //           "screen_name": 'welcome',
                            //           'cta_button_name':
                            //               'cta_welcome_sign_up',
                            //         },
                            //       );
                            //       Navigator.pushNamed(
                            //         context,
                            //         NavigatorName.register,
                            //         arguments: sharedCode,
                            //       );
                            //     },
                            //     child: Container(
                            //         height: 48,
                            //         decoration: BoxDecoration(
                            //             color: R.color.mainColor,
                            //             borderRadius:
                            //                 BorderRadius.circular(200),
                            //             gradient: LinearGradient(
                            //                 begin: Alignment.topLeft,
                            //                 end: Alignment.centerRight,
                            //                 colors: [
                            //                   R.color.greenGradientTop,
                            //                   R.color.greenGradientBottom
                            //                 ])),
                            //         child: Center(
                            //           child: Text(R.string.tao_tai_khoan.tr(),
                            //               style: TextStyle(
                            //                   color: R.color.white,
                            //                   fontSize: 16,
                            //                   fontWeight: FontWeight.w600)),
                            //         )),
                            //   ),
                            // ),
                            // SizedBox(width: 16),
                            GestureDetector(
                              onTap: () async {
                                // Navigator.pushReplacementNamed(
                                //     context, NavigatorName.register,
                                //     arguments: {
                                //       'phone': '0909202394',
                                //     });
                                await TrackingManager.analytics.logEvent(
                                  name: 'cta_button_clicked',
                                  parameters: {
                                    "screen_name": 'welcome',
                                    'cta_button_name': 'cta_welcome_login',
                                  },
                                );

                                Navigator.pushNamed(
                                  context,
                                  NavigatorName.login,
                                  arguments: sharedCode,
                                );
                              },
                              child: Container(
                                height: 52,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F9F7),
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      width: 24,
                                      height: 24,
                                      R.icons.ic_device,
                                      color: R.color.mainColor,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: AutoSizeText(
                                          'Đăng nhập qua số điện thoại',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: R.color.mainColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    SocialLoginSection(),
                    // GestureDetector(
                    //   onTap: () async {
                    //     await TrackingManager.analytics.logEvent(
                    //       name: 'cta_button_clicked',
                    //       parameters: {
                    //         "screen_name": 'welcome',
                    //         'cta_button_name': 'cta_welcome_support',
                    //       },
                    //     );
                    //     if (AppSettings.secureModel != null) {
                    //       Navigator.pushNamed(context, NavigatorName.contact,
                    //           arguments: {'contact': AppSettings.secureModel});
                    //     }
                    //   },
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Image.asset(
                    //         R.drawable.ic_contact,
                    //         width: 19,
                    //         height: 19,
                    //       ),
                    //       SizedBox(
                    //         width: 8,
                    //       ),
                    //       Text(R.string.contact_diab_info.tr(),
                    //           style: TextStyle(
                    //               fontSize: 15,
                    //               color: R.color.captionColorGray)),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 12)
                  ],
                ),
              ],
            ),
            Positioned(
              top: 5,
              right: 5,
              child: ButtonLanguagePicker(screenName: 'welcome'),
            ),
          ],
        ),
      ),
    );
  }

  loginSuccess(String loginFrom) async {
    try {
      await TrackingManager.analytics.logEvent(
        name: 'login',
        parameters: {
          "screen_name": 'login',
          'method': loginFrom.toLowerCase(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  registerAccount(
    String? providerKey,
    String? externalToken,
    String provider,
    String userName,
    bool update, {
    ZaloLoginResult? zaloAccount,
  }) async {
    try {
      Navigator.pushReplacementNamed(context, NavigatorName.update_info,
          arguments: {
            'type': provider.toLowerCase(),
            'googleAccount': null,
            'appleAccount': null,
            'zaloAccount': zaloAccount,
          });
      BotToast.closeAllLoading();
    } catch (error) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, error.toString());
    }
  }

  void loginZalo() async {
    // if (_retry > 3) {
    //   Message.showToastMessage(context, R.string.error_can_not_connect_to_server.tr());
    //   return;
    // }
    ZaloLoginResult? account;
    try {
      _loginZaloProgress = _LoginZaloProgress.inprogress;
      account = await ZaloService().login();
      _loginZaloProgress = _LoginZaloProgress.gottoken;
      BotToast.showLoading();
      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "external",
        "external_token": account.accessToken, // Ensure account is not null
        "provider": 'Zalo',
        "zalo_id": account.id
      });
      final user = await UserClient().fetchUser();
      if (user == null) {
        registerAccount(
          account.id, // Ensure account is not null
          account.accessToken, // Ensure account is not null
          'Zalo',
          account.name,
          true,
          zaloAccount: account,
        );
      } else {
        loginSuccess("Zalo");
        BotToast.closeAllLoading();
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
        if (BranchioLinkConfig.instance.isNavigateToBooking) {
          BranchioLinkConfig.instance
              .navigateTo(NavigatorName.calendar_booking);
        }
      }
    } on ZaloLoginBackException catch (_) {
      _loginZaloProgress = _LoginZaloProgress.none;
      BotToast.closeAllLoading();
    } on ZaloLoginException catch (e, s) {
      _loginZaloProgress = _LoginZaloProgress.none;
      TrackingManager.recordError(e, s);
      BotToast.closeAllLoading();
      Message.showToastMessage(context, "zalo_first_failed_message".tr());
    } catch (error) {
      if (error is Error && error.code == '5' && account != null) {
        registerAccount(
          account.id, // Ensure account is not null
          account.accessToken, // Ensure account is not null
          'Zalo',
          account.name,
          false,
          zaloAccount: account,
        );
      } else if (error is PlatformException && error.code == 'network_error') {
        Message.showToastMessage(
          context,
          R.string.error_can_not_connect_to_server.tr(),
        );
      } else {
        BotToast.closeAllLoading();
        Message.showToastMessage(context, error.toString());
      }
    }
  }

  Widget imageItem(
      BuildContext context, String name, String image, String text) {
    return Image.asset(image);
  }

  Widget builtItemText(String name, String text) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
              color: R.color.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ).tr(),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xFF75797E),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ).tr(),
        ),
      ],
    );
  }

  void _showRetryPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("zalo_first_failed_message".tr()),
        actions: [
          TextButton(
            onPressed: () {
              // close the dialog
              Navigator.pop(context);
            },
            child: Text("action_cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              // close the dialog
              Navigator.pop(context);

              // retry login
              loginZalo();
            },
            child: Text(
              "action_try_again".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
