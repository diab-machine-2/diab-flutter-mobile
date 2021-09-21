import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:package_info/package_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class StepListController extends StatefulWidget {
  @override
  _StepListControllerState createState() => _StepListControllerState();
}

class _StepListControllerState extends State<StepListController> {
  final PageController pageController = PageController();

  var currentPage = 0;

  String name = '';

  var data = [
    {
      'name': R.string.dong_hanh_va_se_chia.tr(),
      'image': R.drawable.im_step1,
      'text':
          R.string.dong_hanh_va_se_chia_description.tr(),
    },
    {
      'name': R.string.hieu_de_yeu_ban_than_hon.tr(),
      'image': R.drawable.im_step2,
      'text':
          R.string.hieu_de_yeu_ban_than_hon_description.tr(),
    },
    {
      'name': R.string.va_khong_chi_co_ban.tr(),
      'image': R.drawable.im_step3,
      'text':
          R.string.va_khong_chi_co_ban_description.tr(),
    }
  ];

  Timer? _timer;

  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    //startTimer();
    getVersion();
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

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {});
  }

  @override
  void dispose() {
    _timer!.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(R.drawable.bg_splash),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Column(
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
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, NavigatorName.register);
                                  },
                                  child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          color: R.color.mainColor,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                R.color.greenGradientTop,
                                                R.color.greenGradientBottom
                                              ])),
                                      child: Center(
                                        child: Text(R.string.tao_tai_khoan.tr(),
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, NavigatorName.login);
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 164,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        border: Border.all(
                                            color: R.color.mainColor, width: 2)),
                                    child: Center(
                                      child: Text(R.string.da_co_tai_khoan.tr(),
                                          style: TextStyle(
                                              color: R.color.mainColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Text('${R.string.version.tr()} $version ($buildNumber)',
                          style: TextStyle(color: R.color.grey)),
                      SizedBox(height: 16)
                    ],
                  )
                ]),
              ]),
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
                color: R.color.mainColor, fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(text,
              style: TextStyle(
                  color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center),
        ),
      ],
    );
    // return null;
  }
}
