import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/food/nutrition_lesson.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

/// Nutrition Guide Page - Hướng dẫn dinh dưỡng
class NutritionGuidePage extends StatefulWidget {
  const NutritionGuidePage({Key? key}) : super(key: key);

  @override
  State<NutritionGuidePage> createState() => _NutritionGuidePageState();
}

class _NutritionGuidePageState extends State<NutritionGuidePage> {
  final List<NutritionLesson> _pinedLessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      _pinedLessons.clear();
      final lessons = await FoodClient().fetchNutritionLessons();
      if (lessons != null) {
        setState(() {
          _pinedLessons.addAll(lessons);
        });
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
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
      backgroundColor: R.color.white,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        leadingWidth: 30,
        centerTitle: false,
        title: Text(
          R.string.huong_dan.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: R.color.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Section - Bạn cần hỗ trợ gì?
            _buildSectionTitle(R.string.what_need_support.tr()),
            const SizedBox(height: 12),
            if (_pinedLessons.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(child: _buildPinnedLessonItem(_pinedLessons[0])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pinedLessons.length > 1
                        ? _buildPinnedLessonItem(_pinedLessons[1])
                        : const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (_pinedLessons.isNotEmpty && _pinedLessons.length > 2) ...[
              Row(
                children: [
                  Expanded(child: _buildPinnedLessonItem(_pinedLessons[2])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pinedLessons.length > 3
                        ? _buildPinnedLessonItem(_pinedLessons[3])
                        : const SizedBox(),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Meal Scoring Image
            _buildSectionTitle(R.string.food_guide_meal_score_question.tr()),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                R.drawable.nuti,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // Nutrient Percentage Image
            _buildSectionTitle(R.string.food_guide_nutrient_group_meaning.tr()),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                R.drawable.chat,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // Nutrition Distribution Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                R.drawable.dinhduong,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // Daily Energy Calculation Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                R.drawable.nhucau,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xff1A1A1A),
      ),
    );
  }

  Widget _buildPinnedLessonItem(NutritionLesson lesson) {
    String title = lesson.name;
    String? imageUrl = lesson.imageUrl;
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson.id, lesson.type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        constraints: BoxConstraints(minHeight: 152.h),
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
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 18 / 13,
                  fontWeight: FontWeight.w400,
                  color: R.color.primaryGreyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
