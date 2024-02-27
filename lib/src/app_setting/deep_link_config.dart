import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkConfig {
  DeepLinkConfig._privateConstructor();
  static final DeepLinkConfig instance = DeepLinkConfig._privateConstructor();

  late StreamSubscription _subUni;
  late StreamSubscription _subLink;

  String? sharedCode;

  static void setUpHandleDeepLink(
      {required Function(String? code) onHaveLink}) {
    linkStream.listen((link) {
      if (link != null &&
          !link.contains("click.diab.com.vn") &&
          !link.contains("referralCode") &&
          !link.contains("activityId") &&
          !link.contains("lessonId") &&
          !link.contains("calendar")) {
        onHaveLink(getShareCodeFromUrl(link));
      } else if (link != null && link.contains("calendar")) {
        DynamicLinkConfig.instance.progressDynamicLink(link);
      }
      // else if (link != null &&
      //     !link.contains("click.diab.com.vn") &&
      //     !link.contains("referralCode") &&
      //     !link.contains("activityId") &&
      //     !link.contains("lessonId") &&
      //     !link.contains("calendar")) {
      //   if (Platform.isAndroid) {
      //     DynamicLinkConfig.instance.progressDynamicLink(link);
      //   }
      // }
    });
  }

  Future<String?> getInitLink() async {
    try {
      final String? initialLink = await getInitialLink();
      if (initialLink != null &&
          !initialLink.contains("click.diab.com.vn") &&
          !initialLink.contains("referralCode") &&
          !initialLink.contains("calendar")) {
        sharedCode = getShareCodeFromUrl(initialLink);
        return sharedCode;
      }
    } on PlatformException {}
    try {
      final Uri? _ = await getInitialUri();
    } on FormatException {}
    return null;
  }

  Future<void> handleDeepLink() async {
    _subLink = linkStream.listen((String? link) {
    }, onError: (err) {});

    _subUni = uriLinkStream.listen((Uri? uri) {
    }, onError: (err) {});
  }

  void dispose() {
    _subLink.cancel();
    _subUni.cancel();
  }

  static String getShareCodeFromUrl(String? url) {
    if (url == null) return '';
    String test = url.substring(url.length - 6, url.length);
    return test;
  }
}
