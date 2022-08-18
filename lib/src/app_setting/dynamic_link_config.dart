import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkConfig {
  DynamicLinkConfig._privateConstructor();
  static final DynamicLinkConfig instance =
      DynamicLinkConfig._privateConstructor();

  String? _referalCode;
  late String _shareLink;

  String? get referalCode => _referalCode;

  Future<void> setUpHandleDeepLink() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      _referalCode = getShareCodeFromUrl(deepLink);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        print("deepLink: $deepLink");
        _referalCode = getShareCodeFromUrl(deepLink);
      }
    }).onError((error) {
      print("onError");
      // Handle errors
    });
    // linkStream.listen((link) {
    //   onHaveLink(getShareCodeFromUrl(link));
    // });
  }

  void shareApp() {
    Share.share(
      'Cùng tham gia DiaB, để sống khoẻ cùng với Đái tháo đường\n$_shareLink',
      subject: 'Sống khoẻ với tiểu đường',
    );
  }

  Future<void> buildDynamicLink() async {
    final user = AppSettings.userInfo!;
    final dynamicLink = FirebaseDynamicLinks.instance;
    String url = "https://diab.page.link";
    String domain = "https://diab.com.vn";
    String longDynamicLink = "https://diab.page.link";
    longDynamicLink += "?link=$domain/referralCode=${user.accountId}";
    longDynamicLink += "&ofl=https://diab.com.vn/giai-phap";
    longDynamicLink += "&apn=com.vbhc.diab";
    longDynamicLink += "&ibi=com.cactusoftware.diab";
    longDynamicLink += "&isi=1569353448";
    longDynamicLink +=
        "&sd=S%E1%BB%91ng%20kho%E1%BA%BB%20c%C3%B9ng%20%C4%91%C3%A1i%20th%C3%A1o%20%C4%91%C6%B0%E1%BB%9Dng.%20N%C6%A1i%20cung%20c%E1%BA%A5p%20ki%E1%BA%BFn%20th%E1%BB%A9c%20to%C3%A0n%20di%E1%BB%87n.%20Gi%C3%BAp%20ng%C6%B0%E1%BB%9Di%20%C4%90%C3%A1i%20th%C3%A1o%20%C4%91%C6%B0%E1%BB%9Dng%20s%E1%BB%91ng%20kho%E1%BA%BB%20m%E1%BA%A1nh%20h%C6%A1n.";
    longDynamicLink +=
        "&si=https%3A%2F%2Fdiab.com.vn%2Fwp-content%2Fuploads%2F2022%2F02%2Fhinh-1-banner-trang-chu.png";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      longDynamicLink: Uri.parse(longDynamicLink),
      link: Uri.parse('$domain/referralCode=${user.accountId}'),
      androidParameters: const AndroidParameters(
        packageName: "com.vbhc.diab",
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        minimumVersion: '0',
        appStoreId: "1569353448",
        bundleId: "com.cactusoftware.diab",
        fallbackUrl: Uri.parse("https://diab.com.vn/giai-phap"),
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        description:
            "Sống khoẻ cùng đái tháo đường. Nơi cung cấp kiến thức toàn diện. Giúp người Đái tháo đường sống khoẻ mạnh hơn.",
        imageUrl: Uri.parse(
            "https://diab.com.vn/wp-content/uploads/2022/02/hinh-1-banner-trang-chu.png"),
        title: "Diab | Giải pháp toàn diện cho người Đái tháo đường",
      ),
    );
    final ShortDynamicLink dynamicUrl =
        await dynamicLink.buildShortLink(parameters);
    _shareLink = dynamicUrl.shortUrl.toString();
  }

  Future<String?> getInitLink() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      _referalCode = getShareCodeFromUrl(deepLink);
    }
    return null;
  }

  static String getShareCodeFromUrl(Uri url) {
    String urlString = url.toString();
    List<String> separatedString = urlString.split('referralCode=');
    return separatedString[1];
  }
}
