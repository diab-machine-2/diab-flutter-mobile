import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/service/zalo_service.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

enum _LoginZaloProgress { none, inprogress, gottoken }

class SyncLoadingController extends StatefulWidget {
  final String phoneNumber;
  final String providerKey;
  final String providerName;

  SyncLoadingController({
    required this.phoneNumber,
    required this.providerKey,
    required this.providerName,
  });

  @override
  _SyncLoadingControllerState createState() => _SyncLoadingControllerState();
}

class _SyncLoadingControllerState extends State<SyncLoadingController> {
  _LoginZaloProgress _loginZaloProgress = _LoginZaloProgress.none;

  @override
  void initState() {
    super.initState();
    handle();
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

  Future<void> handle() async {
    try {
      await LoginClient().syncAccount(
          widget.phoneNumber, widget.providerName, widget.providerKey);
      await AppSettings.logout(isNavigateToStepListScreen: false);
      await loginZalo();
      AppSettings.isSyncSuccess = true;
      await AppSettings.setIsFirstTimeLoginZalo(false);
    } catch (e) {
      Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
      Message.showToastMessage(context, "Quá trình sync data thất bại");
    }
  }

  Future<void> loginZalo() async {
    try {
      BotToast.showLoading();
      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "external",
        "external_token":
            AppSettings.zaloExternalToken, // Ensure account is not null
        "provider": 'Zalo',
        "zalo_id": AppSettings.zaloId
      });
      await UserClient().fetchUser();
      loginSuccess("Zalo");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
    } catch (e) {
      throw e;
    } finally {
      BotToast.closeAllLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                R.color.color0xFFFDC798.withOpacity(0.3),
                R.color.greenbg.withOpacity(0.9),
              ],
              begin: FractionalOffset(1, 1),
              end: FractionalOffset(0.9, 0.5),
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: Image.asset(
                  R.drawable.sync_loading_theme,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Đang đồng bộ...",
                style: TextStyle(
                    fontSize: 18,
                    color: R.color.textDark,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Đang đồng bộ dữ liệu, thao tác có thể mất vài phút.",
                style: TextStyle(fontSize: 16, color: R.color.textDark),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
