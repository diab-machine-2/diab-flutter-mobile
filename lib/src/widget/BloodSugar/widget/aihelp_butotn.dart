import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/constant/bloodSugar_rangetype.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AIHelpButton extends StatelessWidget {
  const AIHelpButton({super.key, required this.rangeType});

  final BloodSugarRangeType? rangeType;

  void _actionByRangeType(BloodSugarRangeType rangeType, BuildContext context) async {
    if (rangeType == BloodSugarRangeType.very_high) {
      const url = Const.ZALO_OA_TECHNICAL_SUPPORT_LINK;
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } else if (rangeType == BloodSugarRangeType.very_low) {
      // TODO: Replace to definition instead
      Navigator.of(context).pushNamed(NavigatorName.dsmes_booking);
    } else {
      // Random a lesson, then navigate to lesson detail
      final glucoseClient = GlucoseClient();
      BotToast.showLoading();
      try {
        final lesson = await glucoseClient.fetchGlucoseUpcommingLesson();
        if (lesson != null) {
          await NavigationUtil.navigatePage(
            context,
            LessonDetailPage(
              lessonType: lesson.type,
              lessonId: lesson.id,
              onComplete: (_, __) {},
            ));
          // _cubit.refreshData(isRefresh: true);
          Observable.instance
              .notifyObservers([], notifyName: "refresh_lesson_tab");
          Observable.instance.notifyObservers([], notifyName: "refresh_home");
        }
      } catch (e) {
        BotToast.showText(text: 'Có lỗi xảy ra, vui lòng thử lại sau');
      } finally {
        BotToast.closeAllLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rangeType != null)
      return ElevatedButton(
        onPressed: () => _actionByRangeType(rangeType!, context),
        child: Center(
          child: Text(
            rangeType == BloodSugarRangeType.very_high
                ? 'Chuyên gia hỗ trợ'
                : rangeType == BloodSugarRangeType.very_low
                    ? 'Tư vấn chuyên gia'
                    : 'Bí quyết ổn định đường huyết',
            style: TextStyle(
              color: R.color.mainColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: R.color.color0xffE1FAF8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          fixedSize: Size(double.infinity, 32),
          elevation: 0,
        ),
      );
    return const SizedBox.shrink();
  }
}
