import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';

import 'dynamic_link_config.dart';

class DeepLinkConfig {
  DeepLinkConfig._privateConstructor();
  static final DeepLinkConfig instance = DeepLinkConfig._privateConstructor();

  late StreamSubscription _subUni;
  late StreamSubscription _subLink;

  String? sharedCode;

  static void setUpHandleDeepLink(
      {required Function(String? code) onHaveLink}) {
    linkStream.listen((link) {
      if (link != null && !link.contains("click.diab.com.vn")) {
        onHaveLink(getShareCodeFromUrl(link));
      }
    });
  }

  Future<String?> getInitLink() async {
    try {
      final String? initialLink = await getInitialLink();
      print('LOG onInit link: $initialLink');
      sharedCode = getShareCodeFromUrl(initialLink);
      return sharedCode;
    } on PlatformException {}
    try {
      final Uri? initialUri = await getInitialUri();
      print('LOG onInit uri.host ${initialUri?.path}');
    } on FormatException {}
    return null;
  }

  Future<void> handleDeepLink() async {
    _subLink = linkStream.listen((String? link) {
      print('LOG onChanged link: $link');
    }, onError: (err) {});

    _subUni = uriLinkStream.listen((Uri? uri) {
      print('LOG onChanged uri.host: ${uri?.host}');
    }, onError: (err) {});
  }

  void dispose() {
    _subLink.cancel();
    _subUni.cancel();
  }

  static String getShareCodeFromUrl(String? url) {
    if (url == null) return '';
    return url.substring(url.length - 6, url.length);
  }
}
