import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/blood_pressure/bloodpressure_lesson.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_functions.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';

import 'widgets/bloodpresure_lesson_section.dart';

class BloodPressureIntro1stPage extends StatefulWidget {
  final String? goalId;
  const BloodPressureIntro1stPage({super.key, this.goalId});

  @override
  State<BloodPressureIntro1stPage> createState() =>
      _BloodPressureIntro1stPageState();
}

class _BloodPressureIntro1stPageState extends State<BloodPressureIntro1stPage> {
  final List<BloodPressureLesson> _pinedLessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      _pinedLessons.clear();
      final lessons = await BloodPressureClient().fetchBloodPressureLessons();
      if (lessons != null) {
        setState(() {
          _pinedLessons.addAll(lessons);
        });
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  void _navigateToInputSelection() async {
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    // Grant access to HealthKit already
    if (hasHealthConnection == true) {
      Navigator.pushNamed(
        context,
        NavigatorName.add_blood_pressure,
        arguments: {'type': 'input', 'goalId': widget.goalId},
      );
      return;
    }
    // Show the modal to choose methods
    BloodPressureFunctions.showModalAddData(context,
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
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _appBarSection(),
          Expanded(child: _composeLayout()),
        ],
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        R.string.huyet_ap.tr(),
        style: TextStyle(
          fontFamily: R.font.sfpro,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
          splashColor: R.color.white,
          highlightColor: R.color.white,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () {
            NavigationUtil.pop(context);
          }),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: R.color.white,
                    fontSize: 15,
                    fontFamily: R.font.sfpro,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
            R.drawable.im_bloodpressure_intro,
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
                    fontSize: 18,
                    fontFamily: R.font.sfpro,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  R.string.bloodpressure_benefit_observe.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    height: 24 / 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.primaryGreyColor,
                    fontFamily: R.font.sfpro,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _navigateToInputSelection,
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                        color: R.color.greenGradientBottom,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom
                            ])),
                    child: Center(
                      child: Text(
                        R.string.enter_blood_pressure.tr(),
                        style: TextStyle(
                          color: R.color.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: R.font.sfpro,
                          letterSpacing: 0.4,
                        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              R.string.bloodpressure_intro_help_title.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                color: R.color.dark,
                fontFamily: R.font.sfpro,
                letterSpacing: 0.2,
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
      child: BloodPressureLessonSection(
        onLessonTap: (lesson) =>
            _navigateToLessonDetail(lesson.id, lesson.type),
      ),
    );
  }

  Widget _buildPinnedLessonItem(BloodPressureLesson lesson) {
    String title = lesson.name;
    String? imageUrl = lesson.imageUrl;
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson.id, lesson.type),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: R.decorationStyle.mediumRadiusCardStyles,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.mediumRadius),
                    topRight: Radius.circular(AppDimens.mediumRadius),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl ?? "",
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.neutral5,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 56,
                        color: AppColors.neutral4,
                      ),
                    ),
                    fit: BoxFit.cover,
                    width: double.maxFinite,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  title,
                  style: R.style.normalTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
