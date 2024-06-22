import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import '../schema/measurement_schema.dart';

class HomeLesson extends StatelessWidget {
  const HomeLesson({
    super.key,
    required this.lessons,
    required this.onLessonTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final List<HomeLessonData> lessons;

  final Function(HomeLessonData) onLessonTap;
  final Function(HomeLessonData) onLike;
  final Function(HomeLessonData) onComment;
  final Function(HomeLessonData) onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 328.0,
      child: ListView.separated(
        itemCount: lessons.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _buildLessonItem(lesson);
        },
        separatorBuilder: (context, index) {
          return SizedBox(width: 12.0);
        },
      ),
    );
  }

  Widget _buildLessonItem(HomeLessonData lesson) {
    return InkWell(
      onTap: () => onLessonTap(lesson),
      child: Container(
        height: 328.0,
        width: 338.0,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            Row(
              children: [
                const SizedBox(width: 16.0),
                Image.asset(
                  lesson.icon,
                  width: 16.0,
                  height: 16.0,
                ),
                const SizedBox(width: 6.0),
                Text(
                  lesson.category,
                  style: TextStyle(
                    color: R.color.color0xff666666,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12.0),

            // Image
            // https://picsum.photos/654/348
            NetWorkImageWidget(
              imageUrl: lesson.imageUrl,
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
                        "${lesson.likeCount}",
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
                        "${lesson.commentCount}",
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
