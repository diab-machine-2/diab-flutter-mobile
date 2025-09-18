import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/glucose/glucose_lesson.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/blood_sugar_functions.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import 'widgets/glucose_lesson_section.dart';

class GlucoseIntro1stPage extends StatefulWidget {
  final String? goalId;
  const GlucoseIntro1stPage({super.key, this.goalId});

  @override
  State<GlucoseIntro1stPage> createState() => _GlucoseIntro1stPageState();
}

class _GlucoseIntro1stPageState extends State<GlucoseIntro1stPage> {
  final List<GlucoseLesson> _pinedLessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      _pinedLessons.clear();
      final lessons = await GlucoseClient().fetchGlucoseLessons();
      if (lessons != null) {
        setState(() {
          _pinedLessons.addAll(lessons);
        });
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  void _navigateToInputSelection() {
    if (!AppSettings.isRegionAllowInputDevice) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(
        NavigatorName.add_blood_sugar_new,
        arguments: {'type': 'input', 'goalId': widget.goalId},
      );
    }
    BloodSugarFunctions.showModalAddData(context,
        popPrevious: true, goalId: widget.goalId);
  }

  void _navigateToLessonDetail(String id, int type) async {
    ActivityListTracking.clickLessonItem(
      objectId: id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: type,
        lessonId: id,
        onComplete: (_, __) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        appbarColor: R.color.greenGradientBottom,
        textColor: Colors.white,
        backgroundColor: R.color.backgroundColorNew,
        title: R.string.duong_huyet.tr(),
        appBarAction: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(NavigatorName.glucose_intro_2nd_page);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
        child: _composeLayout(),
      ),
    );
  }

  Widget _composeLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildBannerSection(),
          const SizedBox(height: 16),
          _buildPinnedLessonsSection(),
          const SizedBox(height: 16),
          _buildLessonSection(),
          const SizedBox(height: 47),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            R.drawable.im_glucose_intro,
            width: 319,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.string.did_you_know.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  R.string.glucose_benefit_observe.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    height: 24 / 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.primaryGreyColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: R.color.mainColor,
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.greenGradientTop,
                        R.color.greenGradientBottom
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _navigateToInputSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      minimumSize: Size.fromHeight(40),
                    ),
                    child: Text(
                      R.string.blood_sugar_input.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedLessonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              R.string.glucose_intro_help_title.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                color: R.color.dark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_pinedLessons.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: _buildPinnedLessonItem(_pinedLessons[0])),
                const SizedBox(width: 8),
                Expanded(
                    child: _pinedLessons.length > 1
                        ? _buildPinnedLessonItem(_pinedLessons[1])
                        : const SizedBox()),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_pinedLessons.isNotEmpty && _pinedLessons.length > 2) ...[
            Row(
              children: [
                Expanded(child: _buildPinnedLessonItem(_pinedLessons[2])),
                const SizedBox(width: 8),
                Expanded(
                    child: _pinedLessons.length > 3
                        ? _buildPinnedLessonItem(_pinedLessons[3])
                        : const SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GlucoseLessonSection(
        onLessonTap: (lesson) =>
            _navigateToLessonDetail(lesson.id, lesson.type),
      ),
    );
  }

  Widget _buildPinnedLessonItem(GlucoseLesson lesson) {
    String title = lesson.name;
    String? imageUrl = lesson.imageUrl;
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson.id, lesson.type),
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
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
