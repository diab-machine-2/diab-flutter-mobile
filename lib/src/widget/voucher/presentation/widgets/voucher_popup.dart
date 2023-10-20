import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app_setting/app_setting.dart';
import '../../../../model/preference/app_preference.dart';
import '../../../../utils/const.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/webview_store.dart';

class PopupStore extends StatefulWidget {
  const PopupStore(
    this._urlPopup, {
    Key? key,
  }) : super(key: key);

  @override
  State<PopupStore> createState() => _PopupStoreState();
  final String _urlPopup;
}

class _PopupStoreState extends State<PopupStore> {
  final String? accessToken = appPreference.getData(Const.TOKEN);
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  var user = AppSettings.userInfo!;
  bool _isChecked = false;
  String get _urlPopup => widget._urlPopup;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Ưu đãi dành cho bạn",
            style: TextStyle(
              //     color: R.color.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.375,
            ),
          ),
          Container(
            height: 30,
            width: 35,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear),
            ),
            margin: EdgeInsets.zero,
          ),
        ],
      ),
      titlePadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      content: GestureDetector(
        onTap: () {
          _analytics.logEvent(
            name: 'component_clicked',
            parameters: {
              "screen_name": 'PopupStore',
              'cta_button_name': 'cta_btn_body_click',
            },
          );
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebviewStore(
                    urlStore:
                        'https://diab.com.vn/cua-hang-diab?p=may-do-duong-huyet'),
              ));
        },
        child: Container(
            margin: EdgeInsets.zero,
            child: CachedNetworkImage(
              imageUrl: _urlPopup,
              fit: BoxFit.fill,
            )),
      ),
      contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      actions: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                        if (value == true) {
                          UserClient().updateCheckedPopup();
                        } else {}
                      });
                    },
                  ),
                  Text(
                    'Không hiển thị lại',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                _analytics.logEvent(
                  name: 'component_clicked',
                  parameters: {
                    "screen_name": 'PopupStore',
                    'cta_button_name': 'cta_btn_watch_now',
                  },
                );
                // _launchWEBSITE();
                Navigator.pop(context);

                //    Future.delayed(Duration(milliseconds: 2), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebviewStore(
                          urlStore:
                              'https://diab.com.vn/cua-hang-diab?p=may-do-duong-huyet'),
                    ));
                //    });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                  child: Text('Xem ngay',
                      style: TextStyle(
                          color: R.color.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // void _launchWEBSITE() async {
  // const url = 'https://diab.com.vn/cua-hang-diab?p=may-do-duong-huyet';
  // if (await canLaunch(url)) {
  //   await launch(url);
  // } else {
  //   throw 'Could not launch $url';
  // }
  // }
}
