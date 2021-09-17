import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailController extends StatefulWidget {
  final String id;
  NotificationDetailController({this.id});
  @override
  _NotificationDetailControllerState createState() =>
      _NotificationDetailControllerState();
}

class _NotificationDetailControllerState
    extends State<NotificationDetailController> {
  NotificationModel notification;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    notification =
        await NotificationClient().fetchNotificationDetail(widget.id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: notification == null
            ? Center(child: CircularProgressIndicator())
            : Container(
                color: R.color.color0xfff5f5f5,
                child: Stack(children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView(padding: EdgeInsets.all(0), children: [
                          Image.network(notification.imageUrl ?? ''),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: R.color.black)),
                                  SizedBox(height: 8),
                                  Html(
                                      data: notification.body,
                                      onLinkTap: (url, context, attributes,
                                          element) async {
                                        await canLaunch(url)
                                            ? await launch(url,
                                                forceSafariVC: false,
                                                forceWebView: false)
                                            : throw 'Could not launch $url';
                                      })
                                ]),
                          )
                        ]),
                      ),
                      GestureDetector(
                        onTap: () {
                          _launchInBrowser(notification.hyperLink);
                        },
                        child: SafeArea(
                          top: false,
                          child: Container(
                              margin: EdgeInsets.all(16),
                              height: 48,
                              width: 195,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(200),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        R.color.greenGradientTop,
                                        R.color.greenGradientBottom
                                      ])),
                              child: Center(
                                  child: Text(notification.hyperText,
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)))),
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CustomAppBar(
                        backgroundColor: R.color.transparent,
                        title: Text(''),
                        leadingIcon: IconButton(
                            splashColor: R.color.transparent,
                            highlightColor: R.color.transparent,
                            icon: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                    color: R.color.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(18)),
                                child: Icon(Icons.arrow_back,
                                    color: R.color.white)),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      )
                    ],
                  )
                ]),
              ));
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
