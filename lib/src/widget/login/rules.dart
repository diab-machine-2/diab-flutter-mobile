import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class RulesController extends StatefulWidget {
  GoogleSignInAccount? googleAccount;
  final Function onConfirm;
  final AuthorizationCredentialAppleID? appleCredential;

  RulesController(
      {this.googleAccount, this.appleCredential, required this.onConfirm});

  static showModal(
    BuildContext context, {
    required Function onConfirm,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return RulesController(onConfirm: () => onConfirm());
      },
    );
  }

  @override
  _RulesControllerState createState() => _RulesControllerState();
}

class _RulesControllerState extends State<RulesController> {
  String? term = '';

  @override
  void initState() {
    super.initState();
    loadData();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics
        .logScreenView(screenName: "privacy", screenClass: "RulesController");
  }

  loadData() async {
    BotToast.showLoading();
    term = await LoginClient().fetchTermAndCondition();
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlockBottomSheet(
      title: '',
      footer: Container(
        margin: EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () async {
            // await TrackingManager.logEvent(
            //   name: 'cta_button_clicked',
            //   parameters: {
            //     "screen_name": 'privacy',
            //     'cta_button_name': 'cta_privacy_accept',
            //   },
            // );
            widget.onConfirm();
            Navigator.maybePop(context);
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
              child: Text(
                R.string.toi_dong_y.tr(),
                style: TextStyle(
                    color: R.color.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(R.string.dieu_khoan_va_dieu_kien.tr(),
                style: TextStyle(
                    color: R.color.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 30.0, left: 16, right: 16, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child:
                      Image.asset(R.drawable.img_logo, width: 87, height: 50),
                ),
                Html(
                    data: term,
                    onLinkTap: (url, attributes, element) {
                      if (url == null) return;
                      launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    })
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
