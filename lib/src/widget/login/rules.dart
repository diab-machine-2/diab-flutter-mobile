import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class RulesController extends StatefulWidget {
  GoogleSignInAccount? googleAccount;
  AuthorizationCredentialAppleID? appleCredential;

  RulesController({this.googleAccount, this.appleCredential});

  @override
  _RulesControllerState createState() => _RulesControllerState();
}

class _RulesControllerState extends State<RulesController> {
  String? term = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    term = await LoginClient().fetchTermAndCondition();
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.white,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(R.drawable.bg_splash),
                fit: BoxFit.cover,
              )),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(R.string.dieu_khoan_va_dieu_kien.tr(),
                      style: TextStyle(color: R.color.black, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0, left: 16, right: 16, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: R.color.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView(padding: EdgeInsets.all(16), children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Image.asset(R.drawable.img_logo, width: 87, height: 50),
                        ),
                        Html(
                            data: term,
                            onLinkTap: (url, context, attributes, element) async {
                              await canLaunch(url!)
                                  ? await launch(url, forceSafariVC: false, forceWebView: false)
                                  : throw 'Could not launch $url';
                            })
                      ]),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () async {
                        BotToast.showLoading();
                        final user = await UserClient().fetchUser();
                        if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) {
                          if (user.phoneNumber!.contains('User')) {
                            if (widget.googleAccount != null || widget.appleCredential != null) {
                              List<CategoryItemUserModel>? diabeteStates;
                              try {
                                diabeteStates = await UserClient().fetchDiabeteStatesNoHeader();
                              } catch (e) {
                                BotToast.closeAllLoading();
                              }
                              BotToast.closeAllLoading();
                              Navigator.pushReplacementNamed(context, NavigatorName.update_info, arguments: {
                                'type': 'google',
                                'googleAccount': widget.googleAccount,
                                'appleAccount': widget.appleCredential,
                                'diabeteStates': diabeteStates
                              });
                            } else {
                              BotToast.closeAllLoading();
                              Navigator.popUntil(context, (route) => route.isFirst);
                              Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
                            }
                          } else {
                            BotToast.closeAllLoading();
                            Navigator.popUntil(context, (route) => route.isFirst);
                            Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
                          }
                        }
                      },
                      child: Container(
                          height: 48,
                          width: 195,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [R.color.greenGradientTop, R.color.greenGradientBottom]),
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Center(
                              child: Text(R.string.toi_dong_y.tr(),
                                  style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w500)))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
//
