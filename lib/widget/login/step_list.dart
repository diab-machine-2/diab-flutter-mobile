import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/modal/user/motivation_model.dart';
import 'package:medical/repo/user/user_client.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/helper/version.dart';
import 'package:package_info/package_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'name': 'Đồng hành & sẻ chia',
      'image': 'assets/images/step1.png',
      'text':
          'Hướng đến những thay đổi lành mạnh cùng đội ngũ huấn luyện sức khỏe (Health Coach)',
    },
    {
      'name': 'Hiểu để yêu bản thân hơn',
      'image': 'assets/images/step2.png',
      'text':
          'Theo dõi sức khỏe dễ dàng, học cách yêu thương bản thân hơn chỉ trên một ứng dụng ',
    },
    {
      'name': 'Và không chỉ có bạn...',
      'image': 'assets/images/step3.png',
      'text':
          'Kết nối bạn với gia đình, cộng đồng người mắc Đái tháo đường suốt hành trình dài phía trước',
    }
  ];

  Timer _timer;

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
    _timer.cancel();
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
          image: AssetImage('assets/images/background_splash.png'),
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
                        final name = data[index]['name'];
                        final image = data[index]['image'];
                        final text = data[index]['text'];
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
                            dotColor: notActiveGreen,
                            activeDotColor: mainColor),
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
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                greenGradientTop,
                                                greenGradientBottom
                                              ])),
                                      child: Center(
                                        child: Text('Tạo tài khoản',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 164,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        border: Border.all(
                                            color: mainColor, width: 2)),
                                    child: Center(
                                      child: Text('Đã có tài khoản',
                                          style: TextStyle(
                                              color: mainColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Text('Version $version ($buildNumber)',
                          style: TextStyle(color: Colors.grey)),
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
                color: mainColor, fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(text,
              style: TextStyle(
                  color: textDark, fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center),
        ),
      ],
    );
    // return null;
  }
}
