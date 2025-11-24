import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/blood_pressure/bloodpressure_lesson.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';

class BloodPressureIntro2ndPage extends StatefulWidget {
  @override
  State<BloodPressureIntro2ndPage> createState() =>
      _BloodPressureIntro2ndPageState();
}

class _BloodPressureIntro2ndPageState extends State<BloodPressureIntro2ndPage> {
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
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: _composeLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        R.string.huong_dan.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.white,
        highlightColor: R.color.white,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () {
          NavigationUtil.pop(context);
        },
      ),
    );
  }

  Widget _composeLayout() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildPinnedLessonsSection(),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildRangeTableSection(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPinnedLessonsSection() {
    return Column(
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
    );
  }

  Widget _buildRangeTableSection() {
    // Màu sắc chính xác theo design Figma
    final Map<String, Map<String, Color>> _colorMap = {
      'Tăng huyết áp độ 3': {
        'label': Color(0xCCAF0000), // rgba(175,0,0,0.8)
        'value': Color(0xFFFFCDD2), // #ffcdd2
      },
      'Tăng huyết áp độ 2': {
        'label': Color(0xB3DC0000), // rgba(220,0,0,0.7)
        'value': Color(0xFFFFE9E9), // #ffe9e9
      },
      'Tăng huyết áp độ 1': {
        'label': Color(0xFFF86F6F), // #f86f6f
        'value': Color(0x99FFE9E9), // rgba(255,233,233,0.6)
      },
      'Bình thường cao': {
        'label': Color(0xD916AA47), // rgba(22,170,71,0.85)
        'value': Color(0xFFEAFFEC), // #eaffec
      },
      'Bình thường': {
        'label': Color(0xFF16AA47), // #16aa47
        'value': Color(0xFFC7F6D7), // #c7f6d7
      },
      'Thấp': {
        'label': Color(0xFFF9BA1A), // #f9ba1a
        'value': Color(0xFFFAF0D2), // #faf0d2
      },
    };

    List<List<String>> rangeTable = [
      ['Mức độ', 'Tâm thu', 'Tâm trương'],
      ['Tăng huyết áp độ 3', '> 180', '> 110'],
      ['Tăng huyết áp độ 2', '160 – 180', '100 – 110'],
      ['Tăng huyết áp độ 1', '140 – 160', '90 – 100'],
      ['Bình thường cao', '130-140', '85-90'],
      ['Bình thường', '90-130', '60-85'],
      ['Thấp', '<90', '<60'],
    ];

    Color _headerBgColor = Color(0xFFF7F8F8);
    final _headerTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      fontFamily: R.font.sfpro,
      color: Color(0xFF636A6B),
      height: 1.5,
    );

    final _valueTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: R.font.sfpro,
      color: R.color.textDark,
      height: 1.5,
      letterSpacing: 0.4,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              'Huyết áp của bạn đang ở ngưỡng nào?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: R.font.sfpro,
                color: R.color.textDark,
                height: 24 / 18,
              ),
            ),
          ),
          // Table header
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: _headerBgColor,
                    border: Border.all(
                      color: Colors.white,
                      width: 0.4,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Center(
                    child: Text(
                      rangeTable[0][0],
                      style: _headerTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: _headerBgColor,
                    border: Border.all(
                      color: Colors.white,
                      width: 0.4,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      rangeTable[0][1],
                      style: _headerTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: _headerBgColor,
                    border: Border.all(
                      color: Colors.white,
                      width: 0.4,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      rangeTable[0][2],
                      style: _headerTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Table rows
          for (var i = 1; i < rangeTable.length; i++)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _colorMap[rangeTable[i][0]]!['label'],
                      border: Border.all(
                        color: Colors.white,
                        width: 0.4,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      rangeTable[i][0],
                      style: _headerTextStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _colorMap[rangeTable[i][0]]!['value'],
                      border: Border.all(
                        color: Colors.white,
                        width: 0.4,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      rangeTable[i][1],
                      style: _valueTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _colorMap[rangeTable[i][0]]!['value'],
                      border: Border.all(
                        color: Colors.white,
                        width: 0.4,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      rangeTable[i][2],
                      style: _valueTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          // Reference info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nguồn tham khảo:\nAbout High Blood Pressure | High Blood Pressure.  (2025, January 28). CDC. Tham khảo ngày 12, tháng 3, 2025, từ https://www.cdc.gov/high-blood-pressure/about/index.html',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontFamily: R.font.sfpro,
                color: Color(0xFFBFC6C6),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
                  style: R.style.normalTextStyle.copyWith(
                    fontFamily: R.font.sfpro,
                  ),
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
