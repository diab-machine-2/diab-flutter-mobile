import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/deep_link_config.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class FlashScreenController extends StatefulWidget {
  @override
  _FlashScreenControllerState createState() => _FlashScreenControllerState();
}

class _FlashScreenControllerState extends State<FlashScreenController> {
  bool isNavigateToStepList = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final String? sharedCode = await DeepLinkConfig.instance.getInitLink();
    try {
      final token = await AppSettings.getToken();
      if (token.isNotEmpty) {
        final refreshToken = await AppSettings.getRefreshToken();
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "refresh_token",
          "refresh_token": refreshToken
        });
        var user = await UserClient().fetchUser();
        if (user == null) {
          if(!isNavigateToStepList) {
              Message.showToastMessage(context, R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
              AppSettings.logout();
              // Navigator.pushReplacementNamed(
              //   context,
              //   NavigatorName.step_list,
              //   arguments: sharedCode,
              // );
              isNavigateToStepList = true;
          }
        } else {
          Navigator.pushReplacementNamed(
            context,
            NavigatorName.tabbar,
            arguments: sharedCode,
          );
        }
      } else {
        Navigator.pushReplacementNamed(
          context,
          NavigatorName.step_list,
          arguments: sharedCode,
        );
      }
    } catch (e) {
      if(!isNavigateToStepList) {
        Message.showToastMessage(context, R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
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
      child: FittedBox(
        child: Image.asset(R.drawable.splash),
        fit: BoxFit.fill,
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
