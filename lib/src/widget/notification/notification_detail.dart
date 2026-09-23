import 'dart:core';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/widgets/shimmer_box.dart';

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
    extends State<NotificationDetailController>
    with SingleTickerProviderStateMixin {
  NotificationListModel? notification;
  bool _loading = true;
  String? _errorMessage;

  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      notification = await NotificationClient()
          .fetchNotificationDetail(widget.id, widget.communicationId);
    } catch (e) {
      _errorMessage = e is Error
          ? (e.message ?? R.string.error_can_not_connect_to_server.tr())
          : e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Console.log('notification', notification);
    return Scaffold(
        body: Stack(children: [
      _loading
          ? _buildLoadingSkeleton()
          : notification == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage ??
                              R.string.error_can_not_connect_to_server.tr(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadData,
                          child: Text(R.string.retry.tr()),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: R.color.color0xfff5f5f5,
                  child: Column(
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
                                        onLinkTap: (url, attributes, element) {
                                          if (url == null) return;
                                          BranchioLinkConfig.instance
                                              .openLink(url);
                                        },
                                      )
                                    ]),
                              )
                            ]),
                      ),
                      Visibility(
                        visible: (notification?.hyperLink != null &&
                            notification!.hyperLink!.isNotEmpty),
                        child: Material(
                          color: R.color.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
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
                        ),
                      )
                    ],
                  ),
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
                    child: Icon(Icons.arrow_back, color: R.color.white)),
                onPressed: () {
                  Navigator.pop(context);
                }),
          )
        ],
      )
    ]));
  }

  /// Shown while [_loadData] is fetching — mirrors the loaded layout's shape
  /// (banner image + title + body lines) instead of a blocking spinner, so
  /// the transition from the notification list into this screen feels
  /// continuous rather than like a hard stop.
  Widget _buildLoadingSkeleton() {
    Widget box({double? width, double height = 14, BorderRadius? radius}) {
      return ShimmerBox(
        animation: _shimmerController,
        width: width,
        height: height,
        borderRadius: radius ?? const BorderRadius.all(Radius.circular(6)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        box(width: double.infinity, height: 280, radius: BorderRadius.zero),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(width: 220, height: 18),
              const SizedBox(height: 12),
              box(width: double.infinity, height: 14),
              const SizedBox(height: 10),
              box(width: double.infinity, height: 14),
              const SizedBox(height: 10),
              box(width: 160, height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchInBrowser(String url) async {
    // openLink() dispatches to Branch (fire-and-forget) or url_launcher —
    // the CTA's own InkWell ripple is the tap feedback; a timed BotToast
    // here was disconnected from real completion and just added a second,
    // unrelated flash before the destination screen's own loading state.
    final opened = await BranchioLinkConfig.instance.openLink(url);
    if (!opened) {
      throw 'Could not launch $url';
    }
  }
}
