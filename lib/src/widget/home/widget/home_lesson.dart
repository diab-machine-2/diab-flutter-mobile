import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class HomeLesson extends StatelessWidget {
  const HomeLesson({
    super.key,
    required this.lessons,
    required this.onLessonTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final List<LearningPostModel> lessons;

  final Function(LearningPostModel) onLessonTap;
  final Function(LearningPostModel) onLike;
  final Function(LearningPostModel) onComment;
  final Function(LearningPostModel) onShare;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor =  max(1.0, MediaQuery.of(context).textScaleFactor);
    final extraTitleHeight = (textScaleFactor - 1) * 60.0;
    return SizedBox(
      height: 320.0 + extraTitleHeight,
      child: ListView.separated(
        itemCount: lessons.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _buildLessonItem(lesson, textScaleFactor);
        },
        separatorBuilder: (context, index) {
          return SizedBox(width: 12.0);
        },
      ),
    );
  }

  Widget _buildLessonItem(LearningPostModel lesson, double extraTitleHeight) {
    return InkWell(
      onTap: () => onLessonTap(lesson),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 320.0 + extraTitleHeight,
        width: 338.0,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      lesson.title,
                      maxLines: 2,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 15.0,
                        height: 24.0 / 15.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  // TODO: Need map
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
                        "Bài học",
                        style: TextStyle(
                          color: R.color.color0xff666666,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12.0),

            // Image
            // https://picsum.photos/654/348
            NetWorkImageWidget(
              imageUrl: lesson.imageUrl.url,
              fit: BoxFit.cover,
              height: 174.0,
              width: double.infinity,
            ),

            const SizedBox(height: 12.0),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 16.0),

                // Like
                InkWell(
                  onTap: () => onLike(lesson),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_like, width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        "0",
                        // "${lesson.likeCount}",
                        style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16.0),

                // Comment
                InkWell(
                  onTap: () => onComment(lesson),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_comment, width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        "0",
                        // "${lesson.commentCount}",
                        style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Share
                InkWell(
                  onTap: () => onShare(lesson),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_share, width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        "Chia sẻ",
                        style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
