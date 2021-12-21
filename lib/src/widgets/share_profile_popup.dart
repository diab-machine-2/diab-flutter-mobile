import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/shared_profile/shared_profile.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../app.dart';
import '../utils/navigation_util.dart';

class ShareProfilePopup {
  static Future<void> onHasSharedCode({
    BuildContext? context,
    required String sharingTitle,
  }) async {
    BotToast.showLoading();
    await Future.delayed(const Duration(seconds: 2));
    BotToast.closeAllLoading();
    final BuildContext currentContext =
        context ?? navigatorKey.currentState!.context;
    showPopup(currentContext,
        image: R.drawable.img_sharing_profile,
        title: sharingTitle,
        description: '''
Việc chia sẽ hồ sơ giúp bác sĩ có thêm thông tin để hỗ trợ chấn đoán và điều trị. Bạn có thể dừng chia sẻ hồ sơ khi không có nhu cầu.
Bạn có muốn tiếp tục chia sẻ không?''', onTapCancel: () {
      NavigationUtil.pop(currentContext);
    }, onTapYes: () async {
      // TODO(Tuyen): Call API to share code
      BotToast.showLoading();
      await Future.delayed(const Duration(seconds: 2));
      BotToast.closeAllLoading();
      NavigationUtil.pop(currentContext);
      showPopup(currentContext,
          image: R.drawable.img_survey_completed,
          title: 'Bạn đã chia sẻ thành công!',
          description: '''
Bạn đã chia sẻ thành công profile 
cho bác sĩ <<tên bác sĩ>>. Bạn có thể dừng chia sẻ tại “danh sách đã chia sẻ”.''',
          onTapYes: () {
        NavigationUtil.pop(currentContext, result: true);
      }, afterShow: () {
        NavigationUtil.navigatePage(currentContext, const SharedProfilePage());
      });
    });
  }

  static Future<void> showPopup(
    context, {
    required String image,
    required String title,
    required String description,
    VoidCallback? onTapCancel,
    required VoidCallback onTapYes,
    VoidCallback? afterShow,
  }) async {
    final result = await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.white,
                      R.color.main_6,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(image),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 20),
                      if (onTapCancel != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 130.w,
                              height: 43,
                              child: ButtonWidget(
                                  title: 'Để sau',
                                  textSize: 14,
                                  backgroundColor: R.color.grayBorder,
                                  textColor: R.color.textDark,
                                  onPressed: onTapCancel),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 130.w,
                              height: 43,
                              child: ButtonWidget(
                                title: 'Xác nhận',
                                textSize: 14,
                                onPressed: onTapYes,
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: 245.w,
                          height: 43,
                          child: ButtonWidget(
                              title: 'Xem danh sách đã chia sẻ',
                              textSize: 14,
                              onPressed: onTapYes),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (result is bool && result && afterShow != null) {
      afterShow.call();
    }
  }
}
