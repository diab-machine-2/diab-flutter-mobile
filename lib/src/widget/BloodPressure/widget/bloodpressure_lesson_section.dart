import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class BloodPressureLessonSection extends StatefulWidget {
  const BloodPressureLessonSection({super.key, required this.onLessonTap});

  final Function(LessonModel) onLessonTap;

  @override
  State<BloodPressureLessonSection> createState() => _BloodPressureLessonSectionState();
}

class _BloodPressureLessonSectionState extends State<BloodPressureLessonSection> {
  final double _lessonItemWidth = 208.0;
  final ScrollController _scrollController = ScrollController();

  final List<LessonModel> _lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchLessons() async {
    // "int get _currentWeek" of HomeBloc
    int type = 1;
    int week = 0;
    if (AppSettings.userInfo?.ownPackage?.ownRoadmap?.currentWeek != null) {
      week = AppSettings.userInfo!.ownPackage!.ownRoadmap!.currentWeek!;
    }
    try {
      final lessons = await LearningClient().fetchGlucoseIntroLessons(type: type, week: week);
      _lessons.addAll(lessons);
      setState(() {});
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lessons.isEmpty) {
      return const SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              R.string.glucose_intro_help_title.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: R.color.dark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List of items
          SizedBox(
            height: 318,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return SizedBox(child: _buildLessonItem(_lessons[index]), height: 318);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 12);
              },
              itemCount: _lessons.length,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return SizedBox(
      height: 200.0,
      width: _lessonItemWidth,
      child: InkWell(
        onTap: () => widget.onLessonTap(lesson),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetWorkImageWidget(
                imageUrl: lesson.image?.url,
                fallbackImageUrl: R.drawable.ic_error_lesson_image,
                fit: BoxFit.cover,
                height: 142.0,
                width: double.infinity,
              ),

              const SizedBox(height: 10),

              Text(
                lesson.name,
                maxLines: 2,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 15.0,
                  height: 24.0 / 15.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
