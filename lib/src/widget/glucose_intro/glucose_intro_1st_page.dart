import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/glucose/glucose_lesson.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/blood_sugar_functions.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class GlucoseIntro1stPage extends StatefulWidget {
  const GlucoseIntro1stPage({super.key});

  @override
  State<GlucoseIntro1stPage> createState() => _GlucoseIntro1stPageState();
}

class _GlucoseIntro1stPageState extends State<GlucoseIntro1stPage> {
  int _currentIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final double _lessonItemWidth = 338.0;

  final List<GlucoseLesson> _pinedLessons = [];

  // seed
  final int _itemCount = 10;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    if (AppSettings.isUS) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(NavigatorName.add_blood_sugar_new);
    }
    BloodSugarFunctions.showModalAddData(context, popPrevious: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        background: R.drawable.bg_glucose,
        title: R.string.duong_huyet.tr(),
        child: _composeLayout(),
        appBarAction: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () {},
            child: Text(
              R.string.huong_dan.tr(),
              style: TextStyle(
                color: R.color.mainColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
          _buildFAQSection(),
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
                ElevatedButton(
                  onPressed: _navigateToInputSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: R.color.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.fromHeight(40),
                  ),
                  child: Text(
                    R.string.blood_sugar_input.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFAQSection() {
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
                Expanded(child: _buildFAQItem(_pinedLessons[0])),
                const SizedBox(width: 8),
                Expanded(
                    child: _pinedLessons.length > 1 ? _buildFAQItem(_pinedLessons[1]) : const SizedBox()),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_pinedLessons.isNotEmpty && _pinedLessons.length > 2) ...[
            Row(
              children: [
                Expanded(child: _buildFAQItem(_pinedLessons[2])),
                const SizedBox(width: 8),
                Expanded(
                    child: _pinedLessons.length > 3 ? _buildFAQItem(_pinedLessons[3]) : const SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
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
              'Kiến thức từ Chuyên gia DiaB',
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
                return SizedBox(child: _buildLessonItem(), height: 318);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 12);
              },
              itemCount: _itemCount,
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 8,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _itemCount; i++)
                    Container(
                      width: _currentIndex == i ? 16 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _currentIndex == i ? R.color.mainColor : Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
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

  Widget _buildFAQItem(GlucoseLesson lesson) {
    String title = lesson.name;
    String? imageUrl = lesson.imageUrl;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
    );
  }

  Widget _buildLessonItem() {
    return SizedBox(
      height: 252.0,
      width: _lessonItemWidth,
      child: InkWell(
        // TODO: add onTap
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              // https://picsum.photos/654/348
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: 'https://picsum.photos/288/174',
                  fit: BoxFit.cover,
                  height: 174.0,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 12.0),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chế độ dinh dưỡng dành cho bệnh đái tháo đường bạn đã biết.',
                        maxLines: 2,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 15.0,
                          height: 24.0 / 15.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
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
              ),

              const SizedBox(height: 12.0),
              Divider(
                height: 1,
                color: R.color.primaryGreyColor,
              ),

              // Actions
              SizedBox(
                height: 40,
                child: Center(
                  child: InkWell(
                    onTap: () {},
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // * Scroll listener
  void _onScroll() {
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _lessonItemWidth;

    int currentIndex = (currentScroll / eachItemWidth).round();
    setState(() {
      _currentIndex = currentIndex;
    });
  }
}
