import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:medical/src/widgets/button_widget.dart';

class BottomSheetShareLesson extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onCancel;
  const BottomSheetShareLesson({
    Key? key,
    required this.onShare,
    required this.onCancel,
  }) : super(key: key);

  static showDialogShareLesson(
    BuildContext context, {
    required VoidCallback onShare,
    required VoidCallback onCancel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetShareLesson(
        onShare: () {
          onShare();
        },
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlockBottomSheet(
      onClose: () {
        // BlockBottomSheet already calls Navigator.pop() before this callback,
        // so we just invoke onCancel for any follow-up navigation.
        onCancel();
      },
      title: 'Chia sẻ bài học',
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(R.drawable.banner_share_lesson),
            SizedBox(height: 25),
            Text(
              "Chúc mừng bạn đã hoàn thành bài học",
              style: TextStyle(
                fontSize: 16,
                color: R.color.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "Nếu bạn thấy bài học này bổ ích hãy chia sẻ cho",
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' người thân ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' & ',
                  ),
                  TextSpan(
                    text: "bạn bè",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    backgroundColor: R.color.white,
                    borderColor: R.color.accentColor,
                    height: 43,
                    textColor: R.color.accentColor,
                    title: R.string.completed.tr(),
                    onPressed: () {
                      // Pop the bottom sheet first to prevent iOS transition conflicts
                      // which cause a black screen when popping multiple routes at once.
                      NavigationUtil.pop(context);
                      onCancel();
                    },
                    textSize: 14,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ButtonWidget(
                    height: 43,
                    title: R.string.share_now.tr(),
                    onPressed: () {
                      onShare();
                    },
                    textSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
