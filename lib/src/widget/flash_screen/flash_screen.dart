import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/deep_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import '../../modal/user/secure.dart';
import '../../model/repository/app_repository.dart';
import '../../model/response/app_version_response.dart';
import '../../model/service/app_client.dart';
import '../helper/version.dart';

class FlashScreenController extends StatefulWidget {
  @override
  _FlashScreenControllerState createState() => _FlashScreenControllerState();
}

class _FlashScreenControllerState extends State<FlashScreenController> {
  bool isNavigateToStepList = false;
  SecureModel? secureModel;
  AppVersionResponse? appVersion;

  @override
  void initState() {
    super.initState();
    isNavigateToStepList = false;
    getSecuredModel();
    getData(context);
    DynamicLinkConfig.instance.setUpHandleDeepLink();
  }

  getSecuredModel() async {
    AppVersionResponse? appVersion;
    try {
      appVersion = await UserClient().getAppVersion(context);
    } catch (error) {
      appVersion = AppVersionResponse(
        id: "cb110991-eb73-4dc7-92ce-50157c3ee359",
        code: "123",
        platform: "iOs",
        enviroment: "production",
        version: "1.1.6",
      );
    }

    try {
      secureModel = await UserClient().fetchInfoSecure();
    } catch (exception) {
      secureModel = SecureModel(
        email: "lienhe@diab.com.vn",
        support: "Supporter",
        hotline: "0768 07 07 27",
        security: "security",
        environment: "production",
      );
    }

    // if(appVersion == null){
    appVersion = AppVersionResponse(
      id: "cb110991-eb73-4dc7-92ce-50157c3ee359",
      code: "123",
      platform: "iOs",
      enviroment: Const.ENVIRONMENT_DEFAULT,
      version: "1.1.6",
    );
    // }

    await AppSettings.saveEnvironment(appVersion.enviroment);
    AppSettings.environment = appVersion.enviroment ?? "";
    AppSettings.secureModel = secureModel;
    AppClient();
    appClient = AppClient().appClient;
  }

  getData(BuildContext context) async {
    final String? sharedCode = await DeepLinkConfig.instance.getInitLink();

    try {
      final token = await AppSettings.getToken();
      AppSettings.environment = await AppSettings.getEnvironment();
      if (token.isNotEmpty) {
        // final refreshToken = await AppSettings.getRefreshToken();
        // await LoginClient().login({
        //   "client_id": Const.CLIENT_ID,
        //   "client_secret": Const.CLIENT_SECRET,
        //   "grant_type": "refresh_token",
        //   "refresh_token": refreshToken
        // });
        var user = await UserClient().getUserPreferences();
        AppSettings.userInfo = user;
        if (user == null) {
          if (!isNavigateToStepList) {
            Message.showToastMessage(context,
                R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
            AppSettings.logout(isNavigateToStepListScreen: false);
            await Navigator.pushReplacementNamed(
              context,
              NavigatorName.step_list,
              arguments: sharedCode,
            );
            isNavigateToStepList = true;
          }
        } else {
          await Navigator.pushReplacementNamed(
            context,
            NavigatorName.tabbar,
            arguments: sharedCode,
          );
        }
      } else {
        await Navigator.pushReplacementNamed(
          context,
          NavigatorName.step_list,
          arguments: sharedCode,
        );
      }
    } catch (e) {
      if (!isNavigateToStepList) {
        Message.showToastMessage(context,
            R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
        AppSettings.logout();
        isNavigateToStepList = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      // decoration: new BoxDecoration(
      //   shape: BoxShape.rectangle,
      //   image: DecorationImage(
      //     fit: BoxFit.fill,
      //     image: AssetImage("assets/images/bg_splash.png"),
      //   ),
      // ),
      child: FittedBox(
        child: Image.asset(R.drawable.splash),
        fit: BoxFit.fill,

        // Column(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           const SizedBox(),
        //           Center(child: Image.asset(R.drawable.img_logo, width: 190, height: 95)),
        //           Padding(
        //             padding: const EdgeInsets.only(bottom: 16),
        //             child: RichText(
        //               text: TextSpan(
        //                 text: '${R.string.cong_ty_co_phan_cong_nghe_y_te.tr()} ',
        //                 style: TextStyle(color: R.color.mainColor, fontSize: 16, fontWeight: FontWeight.w400),
        //                 children: <TextSpan>[
        //                   TextSpan(
        //                       style: TextStyle(color: R.color.mainColor, fontSize: 14, fontWeight: FontWeight.w700),
        //                       text: 'dia-B'),
        //                 ],
        //               ),
        //             ),
        //           )
        //         ],
        //       ),

        // FittedBox(
        //     child: Image.asset(R.drawable.splash),
        //     fit: BoxFit.fill,

        // body: Container(
        //   decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //           colors: [
        //             R.color.color0xFFFDC798.withOpacity(0.5),
        //             R.color.greenbg.withOpacity(0.5),
        //             R.color.greenbg.withOpacity(0.5),
        //             R.color.color0xFFFDC798.withOpacity(0.5),
        //           ],
        //           begin: Alignment.topRight,
        //           end: Alignment.bottomLeft, //FractionalOffset(1.0, 0.0),
        //           stops: const [0.0, 0.3, 0.8, 1.0])),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       const SizedBox(),
        //       Center(child: Image.asset(R.drawable.img_logo, width: 190, height: 95)),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 16),
        //         child: RichText(
        //           text: TextSpan(
        //             text: '${R.string.cong_ty_co_phan_cong_nghe_y_te.tr()} ',
        //             style: TextStyle(color: R.color.mainColor, fontSize: 16, fontWeight: FontWeight.w400),
        //             children: <TextSpan>[
        //               TextSpan(
        //                   style: TextStyle(color: R.color.mainColor, fontSize: 14, fontWeight: FontWeight.w700),
        //                   text: 'dia-B'),
        //             ],
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
