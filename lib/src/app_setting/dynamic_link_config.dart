import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:medical/src/app_setting/app_setting.dart';

class DynamicLinkConfig {
  DynamicLinkConfig._privateConstructor();
  static final DynamicLinkConfig instance =
      DynamicLinkConfig._privateConstructor();

  late StreamSubscription _subUni;
  late StreamSubscription _subLink;

  String? sharedCode;
  late String _referalCode;

  String get referalCode => _referalCode;

  void setUpHandleDeepLink() {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        sharedCode = getShareCodeFromUrl(deepLink);
      }
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      // Handle errors
    });
    // linkStream.listen((link) {
    //   onHaveLink(getShareCodeFromUrl(link));
    // });
  }

  static Future<String> buildDynamicLink() async {
    final user = AppSettings.userInfo!;
    final dynamicLink = FirebaseDynamicLinks.instance;
    String url = "https://diab.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/referalCode=${user.accountId}'),
      androidParameters: const AndroidParameters(
        packageName: "dev.ntp.referral",
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        minimumVersion: '0',
        appStoreId: "1569353448",
        bundleId: "com.cactusoftware.diab",
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
    return dynamicUrl.shortUrl.toString();
  }

  getRefferalCode() async {
    _referalCode = await buildDynamicLink();
  }

  Future<String?> getInitLink() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      sharedCode = getShareCodeFromUrl(deepLink);
    }
    return null;
  }

  

  // Future<void> handleDeepLink() async {
  //   _subLink = linkStream.listen((String? link) {
  //     print('LOG onChanged link: $link');
  //   }, onError: (err) {});

  //   _subUni = uriLinkStream.listen((Uri? uri) {
  //     print('LOG onChanged uri.host: ${uri?.host}');
  //   }, onError: (err) {});
  // }
  // handleDynamicLink(Uri url) {
  //   List<String> separatedString = [];
  //   separatedString.addAll(url.path.split('/'));
  //   if (separatedString[1] == "post") {
  //     // Navigator.push(
  //     //     context,
  //     //     MaterialPageRoute(
  //     //         builder: (context) => PostScreen(separatedString[2])));
  //   }
  // }

  void dispose() {
    _subLink.cancel();
    _subUni.cancel();
  }

  static String getShareCodeFromUrl(Uri url) {
    List<String> separatedString = [];
    separatedString.addAll(url.path.split('/'));
    return separatedString[2];
    // if (separatedString[1] == "referalCode") {
    // if (url == null) return '';
    // return url.substring(url.length - 6, url.length);
  }
}
