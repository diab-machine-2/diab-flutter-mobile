import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/deep_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_language_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../modal/user/secure.dart';
import '../../model/service/app_client.dart';
import '../../repo/user/user_client.dart';

// ignore: must_be_immutable
class StepListController extends StatefulWidget {
  const StepListController(this.sharedCode);
  final String sharedCode;
  @override
  _StepListControllerState createState() => _StepListControllerState();
}

class _StepListControllerState extends State<StepListController> with Observer {
  final PageController pageController = PageController();

  var currentPage = 0;

  String name = '';

  var data = [
    {
      'name': R.string.dong_hanh_va_se_chia,
      'image': R.drawable.img_step1,
      'text': R.string.dong_hanh_va_se_chia_description,
    },
    {
      'name': R.string.hieu_de_yeu_ban_than_hon,
      'image': R.drawable.img_step2,
      'text': R.string.hieu_de_yeu_ban_than_hon_description,
    },
    {
      'name': R.string.va_khong_chi_co_ban,
      'image': R.drawable.img_step3,
      'text': R.string.va_khong_chi_co_ban_description,
    }
  ];

  Timer? _timer;

  String version = '';
  String buildNumber = '';
  String sharedCode = '';
  //SecureModel? secureModel;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
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
    // TrackingManager.analytics.setCurrentScreen(screenName: "Registration Splash Screen");
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "welcome", 
      screenClass: "StepListController"
    );
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      setState(() {});
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(R.drawable.bg_splash),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      child: PageView.builder(
                          onPageChanged: (value) {
                            currentPage = value;
                          },
                          controller: pageController,
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final name = data[index]['name']!;
                            final image = data[index]['image']!;
                            final text = data[index]['text']!;
                            return builtItem(context, name, image, text);
                          }),
                    ),
                    Column(children: [
                      SizedBox(height: 33),
                      Column(
                        children: [
                          SmoothPageIndicator(
                            controller: pageController,
                            count: 3,
                            effect: ExpandingDotsEffect(
                                dotWidth: 5,
                                dotHeight: 5,
                                dotColor: R.color.notActiveGreen,
                                activeDotColor: R.color.mainColor),
                          ),
                          SizedBox(height: 32),
                          Container(
                            margin: EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pushNamed(
                                            context,
                                            NavigatorName.register,
                                            arguments: sharedCode,
                                          );
                                        },
                                        child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                                color: R.color.mainColor,
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      R.color.greenGradientTop,
                                                      R.color
                                                          .greenGradientBottom
                                                    ])),
                                            child: Center(
                                              child: Text(
                                                  R.string.tao_tai_khoan.tr(),
                                                  style: TextStyle(
                                                      color: R.color.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            )),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            NavigatorName.login,
                                            arguments: sharedCode,
                                          );
                                        },
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                              border: Border.all(
                                                  color: R.color.mainColor,
                                                  width: 2)),
                                          child: Center(
                                            child: AutoSizeText(
                                                R.string.da_co_tai_khoan.tr(),
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: R.color.mainColor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (AppSettings.secureModel != null) {
                                Navigator.pushNamed(
                                    context, NavigatorName.contact, arguments: {
                                  'contact': AppSettings.secureModel
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  R.drawable.ic_contact,
                                  width: 19,
                                  height: 19,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(R.string.contact_diab_info.tr(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: R.color.captionColorGray)),
                              ],
                            ),
                          ),
                          SizedBox(height: 12)
                        ],
                      )
                    ]),
                  ]),
              Positioned(
                top: 5,
                right: 5,
                child: ButtonLanguagePicker(screenName: 'welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget builtItem(
      BuildContext context, String name, String image, String text) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      ///mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Image.asset(image)),
        Text(name,
                style: TextStyle(
                    color: R.color.mainColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center)
            .tr(),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(text,
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center)
              .tr(),
        ),
      ],
    );
    // return null;
  }
}
