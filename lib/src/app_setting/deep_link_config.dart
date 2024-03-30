import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
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
      debugPrint('setUpHandleDeepLink > linkStream > $link');
      if (link != null &&
          !link.contains("click.diab.com.vn") &&
          !link.contains("referralCode") &&
          !link.contains("activityId") &&
          !link.contains("lessonId") &&
          !link.contains("calendar")) {
        onHaveLink(getShareCodeFromUrl(link));
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
      debugPrint('getInitLink > getInitialLink > $initialLink');
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
      if (_ != null) {
        debugPrint('getInitLink > getInitialUri > $_');
      } else {
        debugPrint('getInitLink > getInitialUri > null');
      }
    } on FormatException {}
    return null;
  }

  Future<void> handleDeepLink() async {
    _subLink = linkStream.listen((String? link) {
      debugPrint('handleDeepLink > linkStream > $link');
    }, onError: (err) {});

    _subUni = uriLinkStream.listen((Uri? uri) {
      debugPrint('handleDeepLink > uriLinkStream > $uri');
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
