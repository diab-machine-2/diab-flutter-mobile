import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Bmi_temp/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi_temp/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi_temp/views/bmi_on_boarding/widgets/bmi_on_boarding_post_card.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BmiPostSession extends StatefulWidget {
  const BmiPostSession({
    super.key,
  });

  @override
  State<BmiPostSession> createState() => _BmiPostSessionState();
}

class _BmiPostSessionState extends State<BmiPostSession> {
  final PageController _pageController = PageController(
    viewportFraction: 0.75, // mỗi trang chiếm 80% chiều rộng viewport,
  );
  static const _dotSize = 8.0;
  static const _sessionHeight = 360.0;

  late BmiBloc _bmiBloc;

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) => state is BmiGetWeightLessonsState,
        builder: (context, state) {
          if (_bmiBloc.lessons.isEmpty) return const SizedBox();
          return Container(
            decoration: R.decorationStyle.mediumRadiusCardStyles,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.maxFinite,
            height: _sessionHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    R.string.glucose_intro_help_title.tr(),
                    style: R.style.boldXLargeStyle,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: PageView.builder(
                    itemBuilder: (context, index) {
                      EdgeInsetsGeometry? margin;
                      if (index == 0) {
                        margin = EdgeInsets.only(left: 6);
                      } else if (index == 4) {
                        margin = EdgeInsets.only(right: 6);
                      }

                      BmiWeightLesson lesson = _bmiBloc.lessons[index];
                      return BmiOnBoardingPostCard(
                        margin: margin,
                        lesson: lesson,
                        onTap: () =>
                            _navigateToLessonDetail(lesson.id!, lesson.type!),
                      );
                    },
                    itemCount: _bmiBloc.lessons.length,
                    // pageSnapping: false,
                    controller: _pageController,
                    padEnds: false,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _bmiBloc.lessons.length,
                    effect: WormEffect(
                        dotHeight: _dotSize,
                        dotWidth: _dotSize,
                        activeDotColor: R.color.mainColor,
                        dotColor: AppColors.neutral5),
                  ),
                ),
              ],
            ),
          );
        });
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
}
