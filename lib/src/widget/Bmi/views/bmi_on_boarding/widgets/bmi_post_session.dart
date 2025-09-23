import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_on_boarding_post_card.dart';
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

  @override
  Widget build(BuildContext context) {
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              R.string.glucose_intro_help_title.tr(),
              style: R.style.alertTitle,
            ),
          ),
          const SizedBox(height: 12,),
          Expanded(
            child: PageView.builder(
              itemBuilder: (context, index) {
                EdgeInsetsGeometry? margin;
                if (index == 0) {
                  margin = EdgeInsets.only(left: 6);
                } else if (index == 4) {
                  margin = EdgeInsets.only(right: 6);
                }
                return BmiOnBoardingPostCard(
                  margin: margin,
                );
              },
              itemCount: 5,
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
              count: 5,
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
  }
}
