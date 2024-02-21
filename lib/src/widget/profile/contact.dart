
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/secure.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactController extends StatefulWidget {
  final SecureModel? model;
  ContactController({this.model});

  @override
  _ContactControllerState createState() => _ContactControllerState();
}

class _ContactControllerState extends State<ContactController> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      R.color.color0xFFFDC798.withOpacity(0.3),
                      R.color.greenbg.withOpacity(0.9),
                    ],
                    begin: FractionalOffset(1, 1),
                    end: FractionalOffset(0.9, 0.5),
                    stops: [0.0, 1.0])),
            child: Column(children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text(R.string.contact_diab.tr(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Expanded(
                child: ListView(padding: EdgeInsets.all(16), children: [
                  GestureDetector(
                      onTap: () {
                        showDialogCall();
                      },
                      child: Image.asset(R.drawable.img_hotline)),
                  SizedBox(height: 16),
                  GestureDetector(
                      onTap: () async {
                        BotToast.showLoading();
                        final deviceInfor = await NotificationManager.instance
                            .getDeviceInformation();
                        if (deviceInfor == null) return;
                        final PackageInfo packageInfo =
                            await PackageInfo.fromPlatform();
                        BotToast.closeAllLoading();

                        final model = deviceInfor['model'];
                        final systemVersion = deviceInfor['version'] == null
                            ? deviceInfor['systemVersion']
                            : deviceInfor['version']
                                .sdkInt; //as AndroidBuildVersion;
                        final appVersion = packageInfo.version;

                        final Uri _emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: widget.model!.email,
                          // queryParameters: {
                          //   'subject': 'Hỗ trợ diaB',
                          //   'body': 'Version app: $appVersion\nModel: $model\nVersion OS: $systemVersion\n'
                          // },
                         query:
                             'subject=Hỗ trợ diaB&body=Version app: $appVersion\nModel: $model\nVersion OS: $systemVersion\n',
                        );
                        final String _url = _emailLaunchUri.toString();
                        await canLaunch(_url)
                            ? await launch(_url)
                            : throw 'Could not launch $_url';
                      },
                      child: Image.asset(R.drawable.img_email_support))
                ]),
              )
            ])));
  }

  showDialogCall() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_hotline, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            R.string.hotline.tr(args: [widget.model!.hotline!]),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.mes_call_diab.tr(),
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 48,
                                    width: 119,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.cancel.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  final phone =
                                      widget.model!.hotline!.split(' ').join();
                                  launch('tel://$phone');
                                },
                                child: Container(
                                  height: 48,
                                  width: 119,
                                  decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            R.color.greenGradientTop,
                                            R.color.greenGradientBottom
                                          ])),
                                  child: Center(
                                    child: Text(R.string.call.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //   top: 0,
                //   right: 0,
                //   child: IconButton(
                //       icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                //       onPressed: () {
                //         Navigator.pop(context);
                //       }),
                // )
              ])),
        );
      },
    );
  }
}
