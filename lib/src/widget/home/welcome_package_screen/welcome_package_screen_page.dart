import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../model/repository/app_repository.dart';
import 'welcome_package_screen.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomePackageScreenPage extends StatefulWidget {
  final String? icon;
  final String? title;
  final String? subTitle;
  final VoidCallback? onSkip;
  final VoidCallback? onNavigateToMyPlan;

  WelcomePackageScreenPage({Key? key, required this.icon, required this.title, required this.subTitle, required this.onSkip, required this.onNavigateToMyPlan}) : super(key: key);

  @override
  _WelcomePackageScreenPageState createState() => _WelcomePackageScreenPageState();
}

class _WelcomePackageScreenPageState extends State<WelcomePackageScreenPage> {
  late WelcomePackageScreenCubit _cubit;
  bool isClickSkip = false;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = WelcomePackageScreenCubit(appRepository);
    _cubit.getContentWelcome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<WelcomePackageScreenCubit, WelcomePackageScreenState>(
          listener: (context, state) {
            if (state is WelcomePackageScreenLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
          },
          child: BlocBuilder<WelcomePackageScreenCubit, WelcomePackageScreenState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, WelcomePackageScreenState state) {
    return WillPopScope(
      onWillPop: () => _backPressed(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(R.drawable.bg_welcome),
            fit: BoxFit.cover,
          )),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(widget.icon!, width: 220, height: 220,),
                    SizedBox(height: 30),
                    Text(widget.title ?? '',
                        style: TextStyle(color: R.color.mainColor, fontSize: 24, fontWeight: FontWeight.w700)),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child:
                          // Text(widget.subTitle ?? '',
                          //     style: TextStyle(color: R.color.color0xff333333, fontSize: 16, fontWeight: FontWeight.w400),
                          //     textAlign: TextAlign.center),
                          Html(
                        data: '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;line-height: 1">Ch&agrave;o mừng <strong>${_cubit.content?.fullName ?? ''}</strong> đ&atilde; đăng k&yacute; th&agrave;nh c&ocirc;ng g&oacute;i dịch vụ <strong>${_cubit.content?.packageName ?? ''}</strong> của diaB.</span></p>
                          <p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px; line-height: 1;">Để chuẩn bị tốt nhất cho chương tr&igrave;nh của m&igrave;nh, <strong>${_cubit.getGender(_cubit.content?.gender)}</strong> h&atilde;y theo c&aacute;c hướng dẫn sau:</span></p>
                          <ul>
                              <li style="font-family: Arial, Helvetica, sans-serif; font-size: 15px; line-height: 1;">Ho&agrave;n th&agrave;nh c&aacute;c việc trong &quot;Lịch tr&igrave;nh của t&ocirc;i&quot;.</li>
                              <li style="font-family: Arial, Helvetica, sans-serif; font-size: 15px; line-height: 1;">L&agrave;m theo c&aacute;c hướng dẫn từ diaB.</li>
                          </ul>
                          <p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px; line-height: 1;">Li&ecirc;n hệ với diaB khi cần:</span></p>
                          <ul>
                              <li style="font-family: Arial, Helvetica, sans-serif; font-size: 15px; line-height: 1;">Hotline: <strong>${_cubit.content?.hotLine ?? ''}</strong></li>
                              <li style="font-family: Arial, Helvetica, sans-serif; font-size: 15px; line-height: 1;">Email: <a href="mailto:lienhe@diab.com.vn">lienhe@diab.com.vn</a></li>
                          </ul>
                          <p><br></p>''',
                        style: {"body": Style(padding: EdgeInsets.zero, margin: EdgeInsets.zero),},
                        onLinkTap: (url, context, attributes, element) async {
                          await canLaunch(url!)
                              ? await launch(url, forceSafariVC: false, forceWebView: false)
                              : throw 'Could not launch $url';
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                      if(!isClickSkip){
                          isClickSkip = true;
                          await _backPressed();
                        }
                      },
                      child: SafeArea(
                        top: false,
                        child: Container(
                          height: 48,
                          width: 100,
                          child: Center(
                            child: Text(R.string.skip.tr(),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: R.color.mainColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // if(!isClickSkip){
                        //   isClickSkip = true;
                        //   await _backPressed();
                        //   Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
                        // }

                        final zaloGroup =
                            await AppSettings.getZaloGroup() ?? '';
                            final url = Uri.tryParse(zaloGroup);
                        if (zaloGroup.isNotEmpty && url != null) {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }
                      },
                      child: SafeArea(
                        top: false,
                        child: Container(
                            height: 48,
                            width: 180,
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: R.color.mainColor,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                  colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                            child: Center(
                              child: Text(R.string.my_plan.tr(),
                                  style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _backPressed() async {
    await _cubit.markDisplayedWelcome();
    isClickSkip = false;
    Navigator.pop(context);
    return true;
  }
}