import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShare {
  AppShare._privateConstructor();
  static final AppShare instance = AppShare._privateConstructor();

  userReferralCode(BuildContext context, String _shareLink) async {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'Cùng tham gia DiaB, để sống khoẻ cùng với Đái tháo đường\n$_shareLink',
      subject: 'Sống khoẻ với tiểu đường',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
