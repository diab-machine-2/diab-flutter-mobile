import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../modal/notification/notification_list_model.dart';

class NotificationDetailController extends StatefulWidget {
  const NotificationDetailController({this.id, this.communicationId});

  final String? id;
  final String? communicationId;

  @override
  _NotificationDetailControllerState createState() =>
      _NotificationDetailControllerState();
}

class _NotificationDetailControllerState
    extends State<NotificationDetailController> {
  NotificationListModel? notification;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    notification = await NotificationClient()
        .fetchNotificationDetail(widget.id, widget.communicationId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Console.log('notification', notification);
    return Scaffold(
        body: notification == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: R.color.color0xfff5f5f5,
                child: Stack(children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                            padding: const EdgeInsets.all(0),
                            children: [
                              NetWorkImageWidget(
                                  imageUrl: notification?.imageUrl ?? ''),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(notification?.title ?? '',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: R.color.black)),
                                      const SizedBox(height: 8),
                                      Html(
                                          data: notification?.body ?? '',
                                          onLinkTap: (url, context, attributes,
                                              element) async {
                                            await canLaunch(url!)
                                                ? await launch(url,
                                                    forceSafariVC: false,
                                                    forceWebView: false)
                                                : throw 'Could not launch $url';
                                          })
                                    ]),
                              )
                            ]),
                      ),
                      Visibility(
                        visible: (notification?.hyperLink != null &&
                            notification!.hyperLink!.isNotEmpty),
                        child: GestureDetector(
                          onTap: () {
                            _launchInBrowser(notification?.hyperLink ?? '');
                          },
                          child: Container(
                              margin: const EdgeInsets.all(16),
                              width: 195,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        R.color.greenGradientTop,
                                        R.color.greenGradientBottom
                                      ])),
                              child: Center(
                                  child: Text(notification?.hyperText ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)))),
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CustomAppBar(
                        backgroundColor: R.color.transparent,
                        title: const Text(''),
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
      FlutterBranchSdk.handleDeepLink(url);

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
