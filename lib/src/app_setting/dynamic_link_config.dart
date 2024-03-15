import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import '../model/response/lesson_section_list_response.dart';

class DynamicLinkConfig {
  DynamicLinkConfig._privateConstructor();
  static final DynamicLinkConfig instance =
      DynamicLinkConfig._privateConstructor();
  static String _androidApplicationId = "com.vbhc.diab";
  static String _iosBundleId = "com.cactusoftware.diab";
  static String _appStoreId = "1569353448";

  List<String> dynamicLinkTypes = [
    "referralCode",
    "newsDetail",
    "activityId",
  ];

  StreamSubscription? _subLink;
  String? _referalCode;
  String? _lessonId;
  String? _activityId;
  String? _zoomId;
  late String _shareLink;

  String? get referalCode => _referalCode;
  String? get lessonId => _lessonId;
  String? get activityId => _activityId;
  String? get zoomId => _zoomId;
  String? get shareLink => _shareLink;

  Future<void> setUpHandleDeepLink() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      progressDynamicLink(deepLink);
    }

    _subLink = FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        progressDynamicLink(deepLink);
      }
    });
  }

  Future<void> createShareReferralLink() async {
    final user = AppSettings.userInfo!;
    final dynamicLink = FirebaseDynamicLinks.instance;
    String domain = "https://click.diab.com.vn/referralCode";
    String longDynamicLink = "https://click.diab.com.vn/referralCode";
    longDynamicLink +=
        "?link=https://diab.com.vn/referralCode=${user.shareRefCode}";
    longDynamicLink += "&ofl=https://diab.com.vn/giai-phap";
    longDynamicLink += "&apn=com.vbhc.diab";
    longDynamicLink += "&ibi=com.cactusoftware.diab";
    longDynamicLink += "&isi=1569353448";
    longDynamicLink += "&st=Tải ngay ứng dụng diaB";
    longDynamicLink +=
        "&sd=Ứng dụng hoàn toàn miễn phí giúp kiểm soát bệnh đái tháo đường và kết nối với chuyên gia.";
    longDynamicLink +=
        "&si=https://api.diab.com.vn/App/Image/a95ed12f-3880-4588-378f-08dbc2ecc277";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: domain,
      longDynamicLink: Uri.parse(longDynamicLink),
      link: Uri.parse('https://diab.com.vn/referralCode=${user.shareRefCode}'),
      androidParameters: AndroidParameters(
        packageName: "com.vbhc.diab",
        minimumVersion: 70,
        fallbackUrl: Uri.parse("https://diab.com.vn/giai-phap"),
      ),
      navigationInfoParameters:
          NavigationInfoParameters(forcedRedirectEnabled: true),
      iosParameters: IOSParameters(
        minimumVersion: '1.10.0',
        appStoreId: "1569353448",
        bundleId: "com.cactusoftware.diab",
        ipadFallbackUrl: Uri.parse("https://diab.com.vn/giai-phap"),
        fallbackUrl: Uri.parse("https://diab.com.vn/giai-phap"),
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        description:
            "DIAB là ứng dụng hướng dẫn chế độ dinh dưỡng, vận động và thư giãn giúp quản lý đường huyết hiệu quả.",
        imageUrl: Uri.parse(
            "https://diab.com.vn/wp-content/uploads/2022/02/hinh-1-banner-trang-chu.png"),
        title: "Diab | Giải pháp toàn diện cho người Đái tháo đường",
      ),
    );

    final ShortDynamicLink dynamicUrl =
        await dynamicLink.buildShortLink(parameters);
    _shareLink = dynamicUrl.shortUrl.toString();
    _referalCode = null;
  }

  Future<String> createShareLessonLink({
    required LessonSectionItem lesson,
    required String? featureImage,
    required String? lessonDescription,
  }) async {
    final user = AppSettings.userInfo!;
    final dynamicLink = FirebaseDynamicLinks.instance;

    String lessonImage = featureImage ??
        "https://diab.com.vn/wp-content/uploads/2022/02/hinh-1-banner-trang-chu.png";

    String lessonName = lesson.name ??
        "Tải ngay DiaB để xem bài học trên và còn nhiều hướng dẫn về chế độ dinh dưỡng, vận động, nghỉ ngơi cho người đái tháo đường!";

    String domain = "https://click.diab.com.vn/referralCode";
    String longDynamicLink = "https://click.diab.com.vn/referralCode";
    longDynamicLink +=
        "?link=https://diab.com.vn/referralCode=${user.shareRefCode}?lessonId=${lesson.lessonId}";
    longDynamicLink += "&ofl=https://diab.com.vn/giai-phap";
    longDynamicLink += "&st=$lessonName";
    longDynamicLink += "&apn=com.vbhc.diab";
    longDynamicLink += "&ibi=com.cactusoftware.diab";
    longDynamicLink += "&isi=1569353448";
    longDynamicLink += "&sd=$lessonDescription";
    longDynamicLink += "&si=$lessonImage";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: domain,
      longDynamicLink: Uri.parse(longDynamicLink),
      link: Uri.parse(
          'https://diab.com.vn/referralCode=${user.shareRefCode}?lessonId=${lesson.lessonId}'),
    );

    final ShortDynamicLink dynamicUrl =
        await dynamicLink.buildShortLink(parameters);
    return dynamicUrl.shortUrl.toString();
  }

  removeLessonId() {
    _lessonId = null;
  }

  removeActivityId() {
    _activityId = null;
  }

  void removeZoomId() {
    _zoomId = null;
  }

  void setZoomId(String zoomId) {
    _zoomId = zoomId;
  }

  static Future<String?> createShareNewsLink(
      LearningPostModel newsDetail) async {
    String _fallbackUrl = "https://diab.com.vn/cau-chuyen-thanh-cong";
    String _domainShareLink = "https://news.diab.com.vn/referralCode";
    String _link = "https://diab.com.vn/newsDetail=${newsDetail.id}";
    String _shareTitle = newsDetail.title;
    String _shareDesription = "hihi";
    String _shareBanner = newsDetail.imageUrl.url != null
        ? newsDetail.imageUrl.url!
        : "https://diab.com.vn/wp-content/uploads/2022/02/hinh-1-banner-trang-chu.png";
    String _androidMininumVersion = "70";
    String _iosMininumVersion = "1.2.0";

    final dynamicLink = FirebaseDynamicLinks.instance;
    String longDynamicLink = "$_domainShareLink";
    longDynamicLink += "?link=$_link";
    longDynamicLink += "&st=$_shareTitle";
    longDynamicLink += "&isi=$_appStoreId";
    longDynamicLink += "&si=$_shareBanner";
    longDynamicLink += "&ofl=$_fallbackUrl";
    longDynamicLink += "&ibi=$_iosBundleId";
    longDynamicLink += "&sd=$_shareDesription";
    longDynamicLink += "&imv=$_iosMininumVersion";
    longDynamicLink += "&amv=$_androidMininumVersion";
    longDynamicLink += "&apn=$_androidApplicationId";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: _domainShareLink,
      longDynamicLink: Uri.parse(longDynamicLink),
      link: Uri.parse(_link),
    );

    final ShortDynamicLink dynamicUrl =
        await dynamicLink.buildShortLink(parameters);
    return dynamicUrl.shortUrl.toString();
  }

  Future<String?> getInitLink() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      progressDynamicLink(deepLink);
    }
    return null;
  }

  void progressDynamicLink(Uri deepLink) {
    String urlString = deepLink.toString();

    // Zoom handler
    String meetUrl = "meet.diab.com.vn";
    if (urlString.contains(meetUrl)) {
      String roomId = urlString.split(meetUrl + "/").last;
      final UserModel? user = AppSettings.userInfo;
      if (user != null && _zoomId == null) {
        _zoomId = roomId;
        ZoomService().launchZoom(roomId, AppSettings.userInfo?.fullName ?? 'Người dùng',
            navigatorKey.currentState!.context);
      } else {
        _zoomId = roomId;
      }
      return;
    }

    // Other handlers (old)
    dynamicLinkTypes.forEach((functionName) async {
      List<String> separatedString = urlString.split('$functionName=');
      switch (functionName) {
        case "referralCode":
          if (urlString.contains(functionName)) {
            _referalCode = separatedString[1].substring(0, 6);
            Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_REGISTER);
          }
          if (urlString.contains('lessonId')) {
            _lessonId = urlString.split('lessonId=').last;
            Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_DETAIL);
          }
          if (urlString.contains('activityId')) {
            _activityId = urlString.split('activityId=').last;
            Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_ACTIVITY_DETAIL);
          }
          break;
        case "newsDetail":
          if (urlString.contains(functionName)) {
            String newsDetailId = separatedString[1];
            Navigator.pushNamed(navigatorKey.currentState!.context, NavigatorName.news_detail,
                arguments: {'id': newsDetailId});
          }
          break;
      }
    });
  }

  void dispose() {
    _subLink?.cancel();
  }
}
