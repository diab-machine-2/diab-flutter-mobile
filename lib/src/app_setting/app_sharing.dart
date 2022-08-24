import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShare {
  AppShare._privateConstructor();
  static final AppShare instance = AppShare._privateConstructor();

  userReferralCode(BuildContext context, String _shareLink) async {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'Cùng DiaB làm chủ đường huyết, sống khỏe cùng Đái tháo đường!\n$_shareLink',
      subject: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
