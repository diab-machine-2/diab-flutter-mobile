import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';

class DeepLinkConfig {
  DeepLinkConfig._privateConstructor();
  static final DeepLinkConfig instance = DeepLinkConfig._privateConstructor();

  late StreamSubscription _subUni;
  late StreamSubscription _subLink;

  String? sharedCode;

  Future<void> initUniLinks() async {
    try {
      final String? initialLink = await getInitialLink();
      print('LOG onInit link: $initialLink');
      sharedCode = initialLink;
    } on PlatformException {}
    try {
      final Uri? initialUri = await getInitialUri();
      print('LOG onInit uri.host ${initialUri?.host}');
      sharedCode = initialUri?.scheme;
    } on FormatException {}
  }

  Future<void> handleDeepLink() async {
    initUniLinks();
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
}
