import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class HbA1cHelpSection extends StatefulWidget {
  const HbA1cHelpSection({Key? key}) : super(key: key);

  @override
  State<HbA1cHelpSection> createState() => _HbA1cHelpSectionState();
}

class _HbA1cHelpSectionState extends State<HbA1cHelpSection> {
  final List<LessonModel> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      setState(() => _isLoading = true);
      _lessons.clear();
      final lessons = await HbA1CClient().fetchHbA1CLessons();
      if (mounted) {
        setState(() {
          _lessons.addAll(lessons);
          _isLoading = false;
        });
      }
    } catch (e, s) {
      print('❌ Error loading HbA1C help lessons: $e');
      TrackingManager.recordError(e, s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLessonDetail(LessonModel lesson) async {
    ActivityListTracking.clickLessonItem(
      objectId: lesson.id,
      objectIndex: null,
      objectTitle: lesson.name,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: lesson.type,
        lessonId: lesson.id,
        onComplete: (_, __) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            "Bạn cần hỗ trợ gì?",
            style: TextStyle(
              fontSize: 18,
              fontFamily: R.font.sfpro,
              fontWeight: FontWeight.w700,
              height: 24 / 18,
              letterSpacing: 0.2,
              color: R.color.dark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _isLoading
            ? _buildLoadingState()
            : _lessons.isEmpty
                ? const SizedBox()
                : _buildLessonsGrid(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 312, // 2 rows * (152 + 8)
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(R.color.mainColor),
        ),
      ),
    );
  }

  Widget _buildLessonsGrid() {
    return Column(
      children: [
        if (_lessons.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: _buildLessonItem(_lessons[0])),
              const SizedBox(width: 8),
              Expanded(
                child: _lessons.length > 1
                    ? _buildLessonItem(_lessons[1])
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (_lessons.length > 2) ...[
          Row(
            children: [
              Expanded(child: _buildLessonItem(_lessons[2])),
              const SizedBox(width: 8),
              Expanded(
                child: _lessons.length > 3
                    ? _buildLessonItem(_lessons[3])
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        height: 152.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: R.color.grayComponentBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NetWorkImageWidget(
              imageUrl: lesson.image?.url,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  lesson.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 20 / 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                    fontFamily: R.font.sfpro,
                    color: R.color.hba1c_text_color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
