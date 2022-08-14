import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:share_plus/share_plus.dart';

class ReferralCode extends StatelessWidget {
  const ReferralCode({Key? key}) : super(key: key);

  static onShareApp(BuildContext context) async {
    String refferalCode = await buildDynamicLink();
    print("_refferalCode: $refferalCode");

    await FlutterShare.share(
      text: 'Diab | Sống khoẻ với tiểu đường',
      title: 'Cùng tham gia DiaB, để sống khoẻ cùng với Đái tháo đường',
      linkUrl: refferalCode,
      chooserTitle: 'Example Chooser Title',
    );
    // final box = context.findRenderObject() as RenderBox?;
    // await Share.share("text",
    //     subject: "subject",
    //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);

    // setState(() {
    //   refferalCode = _refferalCode;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.color.mainColor,
      height: 300,
      width: 200,
      alignment: Alignment.center,
      child: Text(
        "refferalCode",
        style: TextStyle(
          color: R.color.white,
          fontSize: 23,
        ),
      ),
    );
  }
}
