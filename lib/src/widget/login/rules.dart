import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class RulesController extends StatefulWidget {
  @override
  _RulesControllerState createState() => _RulesControllerState();
}

class _RulesControllerState extends State<RulesController> {
  String term = '';

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
                  child: Text('Điều khoản & điều kiện',
                      style: TextStyle(
                          color: R.color.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 16, right: 16, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: R.color.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView(padding: EdgeInsets.all(16), children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Image.asset(R.drawable.im_logo,
                              width: 87, height: 50),
                        ),
                        Html(
                            data: term,
                            onLinkTap:
                                (url, context, attributes, element) async {
                              await canLaunch(url)
                                  ? await launch(url,
                                      forceSafariVC: false, forceWebView: false)
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
                        await UserClient().fetchUser();
                        BotToast.closeAllLoading();
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
                      },
                      child: Container(
                          height: 48,
                          width: 195,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  R.color.greenGradientTop,
                                  R.color.greenGradientBottom
                                ]),
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Center(
                              child: Text('Tôi đồng ý',
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)))),
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
