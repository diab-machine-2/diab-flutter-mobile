import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

typedef OnLessonTap = void Function(LessonModel lesson);

class HomeLesson extends StatelessWidget {
  const HomeLesson({
    super.key,
    required this.lessons,
    required this.onLessonTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.showGutter = false,
  });

  final List<LessonModel> lessons;

  final OnLessonTap onLessonTap;
  final OnLessonTap onLike;
  final OnLessonTap onComment;
  final OnLessonTap onShare;
  final bool showGutter;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = max(1.0, MediaQuery.of(context).textScaleFactor);
    final extraTitleHeight = (textScaleFactor - 1) * 60.0;
    return SizedBox(
      height: 300.0 + extraTitleHeight,
      child: ListView.separated(
        itemCount: lessons.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          if (showGutter) {
            // Add padding to the first and last items
            // to create a gutter effect
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildLessonItem(lesson, extraTitleHeight),
              );
            }
            if (index == lessons.length - 1) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildLessonItem(lesson, extraTitleHeight),
              );
            }
          }
          // For all other items, no padding
          return _buildLessonItem(lesson, textScaleFactor);
        },
        separatorBuilder: (context, index) {
          return SizedBox(width: 12.0);
        },
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson, double extraTitleHeight) {
    return InkWell(
      onTap: () => onLessonTap(lesson),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 300.0 + extraTitleHeight,
        width: 338.0,
        padding: const EdgeInsets.only(top: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: SizedBox(
                    height: 32,
                    child: Text(
                      lesson.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 15.0,
                        height: 24.0 / 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Category
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16.0),
                    Image.asset(
                      R.drawable.ic_lesson_category,
                      width: 16.0,
                      height: 16.0,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      lesson.module,
                      style: TextStyle(
                        color: R.color.color0xff666666,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12.0),

            // Image
            // https://picsum.photos/654/348
            NetWorkImageWidget(
              imageUrl: lesson.image?.url,
              fallbackImageUrl: R.drawable.ic_error_lesson_image,
              fit: BoxFit.cover,
              height: 174.0,
              width: double.infinity,
            ),

            const SizedBox(height: 12.0),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const SizedBox(width: 16.0),

                // Like
                // InkWell(
                //   onTap: () => onLike(lesson),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Image.asset(R.drawable.ic_lesson_like, width: 20.0, height: 20.0),
                //       const SizedBox(width: 8.0),
                //       Text(
                //         "0",
                //         // "${lesson.likeCount}",
                //         style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                //       ),
                //     ],
                //   ),
                // ),

                // const SizedBox(width: 16.0),

                // Comment
                // InkWell(
                //   onTap: () => onComment(lesson),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Image.asset(R.drawable.ic_lesson_comment, width: 20.0, height: 20.0),
                //       const SizedBox(width: 8.0),
                //       Text(
                //         "0",
                //         // "${lesson.commentCount}",
                //         style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                //       ),
                //     ],
                //   ),
                // ),

                // const Spacer(),

                // Share
                InkWell(
                  onTap: () => onShare(lesson),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_share,
                          width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        R.string.share.tr(),
                        style:
                            TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                // const SizedBox(width: 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
