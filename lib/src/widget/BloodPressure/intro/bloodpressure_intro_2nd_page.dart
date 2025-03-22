import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/glucose/glucose_lesson.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodPressureIntro2ndPage extends StatefulWidget {
  @override
  State<BloodPressureIntro2ndPage> createState() => _BloodPressureIntro2ndPageState();
}

class _BloodPressureIntro2ndPageState extends State<BloodPressureIntro2ndPage> {
  final List<GlucoseLesson> _pinedLessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      _pinedLessons.clear();
      // TODO: BLOOD PRESSURE
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
        background: R.drawable.bg_glucose,
        title: R.string.huong_dan.tr(),
        child: _composeLayout(),
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
    // ref: _colorList
    final Map<String, Color> _colorMap = {
      'Tăng huyết áp độ 3': Color(0xFFAF0000),
      'Tăng huyết áp độ 2': Color(0xFFDC0000),
      'Tăng huyết áp độ 1': Color(0xFFF86F6F),
      'Bình thường cao': Color(0xFF16AA47),
      'Bình thường': Color(0xFF16AA47),
      'Thấp': Color(0xFFF9BA1A),
    };
    // Mức độ Tâm thu Tâm trương
    // Tăng huyết áp độ 3  > 180   > 110
    // Tăng huyết áp độ 2  160 – 180 100 – 110
    // Tăng huyết áp độ 1 140 – 160 90 – 100
    // Bình thường cao 130-140 85-90
    // Bình thường 90-130 60-85
    // Thấp <90 <60
    List<List<String>> rangeTable = [
      ['Mức độ', 'Tâm thu', 'Tâm trương'],
      ['Tăng huyết áp độ 3', '>180', '>110'],
      ['Tăng huyết áp độ 2', '160-180', '100-110'],
      ['Tăng huyết áp độ 1', '140-160', '90-100'],
      ['Bình thường cao', '130-140', '85-90'],
      ['Bình thường', '90-130', '60-85'],
      ['Thấp', '<90', '<60'],
    ];
    Color _headerBgColor = Color(0xFFF7F8F8);
    final _headerTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: R.color.color0xff636A6B,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: R.color.gray_btn),
      ),
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              'Huyết áp của bạn đang ở ngưỡng nào?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: R.color.textDark,
              ),
            ),
          ),
          // Table range
          ColoredBox(
            color: _headerBgColor,
            child: Row(
              children: [
                for (var i = 0; i < rangeTable[0].length; i++)
                  Expanded(
                    child: SizedBox(
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          rangeTable[0][i],
                          style: _headerTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      )),
                      height: 64,
                    ),
                    flex: i == 0 ? 3 : 1,
                  ),
              ],
            ),
          ),
          for (var i = 1; i < rangeTable.length; i++)
            Row(
              children: [
                for (var j = 0; j < rangeTable[i].length; j++)
                  Expanded(
                    flex: j == 0 ? 3 : 1,
                    child: Container(
                      color: j == 0
                          ? _colorMap[rangeTable[i][0]]
                          : _colorMap[rangeTable[i][0]]?.withOpacity(0.1),
                      alignment: j == 0 ? Alignment.centerLeft : Alignment.center,
                      padding: j == 0 ? const EdgeInsets.only(left: 12) : null,
                      child: Text(
                        rangeTable[i][j],
                        textAlign: TextAlign.center,
                        style: j == 0
                            ? _headerTextStyle.copyWith(
                                color: Colors.white,
                              )
                            : TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: R.color.textDark,
                              ),
                      ),
                      height: 52,
                      width: double.infinity,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 12),
          // Reference info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: R.color.captionColorGray,
                ),
                children: [
                  TextSpan(
                    text: 'Nguồn tham khảo:\nAbout High Blood Pressure | High Blood Pressure.  (2025, January 28). CDC. Tham khảo ngày 12, tháng 3, 2025, từ ',
                  ),
                  TextSpan(
                    text: 'https://www.cdc.gov/high-blood-pressure/about/index.html',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          launchUrl(Uri.parse('https://www.cdc.gov/high-blood-pressure/about/index.html')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
