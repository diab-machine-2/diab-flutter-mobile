import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';

class LessonStatusWidget extends StatelessWidget {
  const LessonStatusWidget({
    required this.learningStatus,
    this.progress,
  });
  final int? learningStatus;
  final int? progress;

  @override
  Widget build(BuildContext context) {
    if (learningStatus == Const.LESSON_LEARNT) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 20.w,
            color: R.color.greenGradientBottom,
          ),
          SizedBox(width: 8.w),
          Text(
            R.string.complete_lesson.tr(),
            style: TextStyle(
              color: R.color.greenGradientBottom,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    if (learningStatus == Const.LESSON_LEARNING && progress != null) {
      return Row(
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: LinearProgressIndicator(
                value: (progress ?? 0) / 100,
                minHeight: 2,
                backgroundColor: R.color.grayBorder,
                valueColor:
                    AlwaysStoppedAnimation<Color>(R.color.greenGradientBottom),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$progress%',
            style: TextStyle(
              color: R.color.greenGradientBottom,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    if (learningStatus == Const.LESSON_NOT_LEARN ||
        learningStatus == Const.LESSON_LEARNING && progress == null) {
      return Row(
        children: [
          Container(
            width: 20,
            height: 20,
            child: Image.asset(R.drawable.ic_lesson_not_learn),
          ),
          const SizedBox(width: 8),
          Text(
            R.string.lesson_not_learnt_yet.tr(),
            style: TextStyle(
              color: R.color.captionColorGray,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    if (learningStatus == Const.LESSON_LOCKED ||
        learningStatus == Const.LESSON_CAN_NOT_LEARN) {
      return Row(
        children: [
          Container(
            width: 20,
            height: 20,
            child: Image.asset(learningStatus == Const.LESSON_LOCKED
                ? R.drawable.ic_lesson_lock
                : R.drawable.ic_lesson_can_not_learn),
          ),
          const SizedBox(width: 8),
          Text(
            learningStatus == Const.LESSON_LOCKED
                ? R.string.lesson_not_unlock_yet.tr()
                : R.string.lesson_can_not_learn.tr(),
            style: TextStyle(
              color: R.color.captionColorGray,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
