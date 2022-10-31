import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:share_plus/share_plus.dart';

class AppShare {
  AppShare._privateConstructor();
  static final AppShare instance = AppShare._privateConstructor();

  userReferralCode(BuildContext context, String _shareLink) async {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'Tải ngay DiaB để được hướng dẫn chế độ dinh dưỡng, vận động, nghỉ ngơi cho người đái tháo đường\n$_shareLink',
      subject: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void lessonDetail(BuildContext context, String _shareLink) async {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'Tải ngay DiaB để được hướng dẫn chế độ dinh dưỡng, vận động, nghỉ ngơi cho người đái tháo đường\n$_shareLink',
      subject: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    // final success = await FlutterShare.share(
    //   text:
    //       'Tải ngay DiaB để được hướng dẫn chế độ dinh dưỡng, vận động, nghỉ ngơi cho người đái tháo đường',
    //   title: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
    //   linkUrl: _shareLink,
    //   chooserTitle: 'Example Chooser Title',
    // );
    // return success;
  }

  shareNews(BuildContext context, String _shareLink) {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'DiaB hướng dẫn chế độ dinh dưỡng, vận động, nghỉ ngơi cho người đái tháo đường\n$_shareLink',
      subject: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
