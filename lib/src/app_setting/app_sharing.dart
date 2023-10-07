import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:share_plus/share_plus.dart';

class AppShare {
  AppShare._privateConstructor();
  static final AppShare instance = AppShare._privateConstructor();

  userReferralCode(BuildContext context, String _shareLink) async {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'Ứng dụng DiaB giúp bạn cải thiện sức khỏe bằng cách đơn giản hóa việc theo dõi chỉ số đường huyết, kết nối tư vấn cùng bác sĩ và thỏa thích lướt xem video hướng dẫn kiểm soát đường huyết hiệu quả. Nhấp vào hình ảnh bên dưới để tải ứng dụng ngay!\n$_shareLink',
      subject: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void lessonDetail(BuildContext context, String _shareLink, String lessonName) async {
    final box = context.findRenderObject() as RenderBox?;
    final user = AppSettings.userInfo!;
    Share.share(
      '${user.fullName} đã chia sẻ cho bạn bài học $lessonName từ ứng dụng DiaB - ứng dụng tự quản lý bệnh đái tháo đường và kết nối với chuyên gia.\n$_shareLink',
      subject: 'DIAB | Ứng dụng giúp quản lý đường huyết hiệu quả',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
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
