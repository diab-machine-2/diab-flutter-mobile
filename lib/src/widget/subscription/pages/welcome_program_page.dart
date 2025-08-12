import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widget/subscription/model/package_program_model.dart';
import 'package:medical/src/widget/subscription/services/package_program_service.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class WelcomeProgramPage extends StatefulWidget {
  final PackageProgram program;

  const WelcomeProgramPage({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  State<WelcomeProgramPage> createState() => _WelcomeProgramPageState();
}

class _WelcomeProgramPageState extends State<WelcomeProgramPage> {
  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void _navigateToHomeScreen() async {
    await TrackingManager.trackEvent(
      'program_subs_welcome',
      'program_activation',
      params: {
        'cta_button_name': R.string.back_home_page.tr(),
      },
    );
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      NavigatorName.tabbar,
      (route) => false, // This removes all routes from stack
    );
  }

  void _learnMoreAboutProgram() async {
    await TrackingManager.trackEvent(
      'program_subs_welcome',
      'program_activation',
      params: {
        'cta_button_name': R.string.explore_program.tr(),
      },
    );
    // Implement navigation to program details or info page
    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: 1,
        lessonId: '43b767c7-4088-477f-e4cd-08d9ec6038bc',
        onComplete: (lessonId, percentComplete) {
          // Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          //   NavigatorName.tabbar,
          //   (route) => false, // This removes all routes from stack
          // );
        },
      ),
    );
  }

  Widget _buildActivatedContent() {
    return Column(
      children: [
        Text(
          R.string.waiting_active_subscription_content_2.tr(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF636A6B),
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        GapH(20),
        InkWell(
          onTap: _learnMoreAboutProgram,
          child: Container(
            height: 42,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  R.color.greenGradientTop02,
                  R.color.greenGradientBottom,
                ],
              ),
              borderRadius: BorderRadius.circular(200),
            ),
            child: Center(
              child: Text(
                R.string.explore_program.tr(),
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        GapH(12),
        InkWell(
          onTap: _navigateToHomeScreen,
          child: Container(
            height: 42,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFDCFFFC),
              borderRadius: BorderRadius.circular(200),
            ),
            child: Center(
              child: Text(
                R.string.back_home_page.tr(),
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.greenGradientTop02,
                  R.color.greenGradientBottom
                ],
                stops: const [0.01, 0.99],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: CustomAppBar(
              hideAllBackButton: true,
              backgroundColor: Colors.transparent,
              title: Text(
                R.string.basic_program.tr(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: R.color.white),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    HomeSupportFunctions.showModalAddData(context);
                  },
                  child: Container(
                    height: 36,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    margin: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: R.color.color0xffCAFAF5,
                      border: Border.all(
                        color: R.color.color0xff8FEBE0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          R.icons.ic_telephone,
                          width: 16,
                          height: 16,
                          color: R.color.greenGradientBottom,
                          fit: BoxFit.scaleDown,
                        ),
                        GapW(4),
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: MediaQuery.of(context).textScaler.clamp(
                                minScaleFactor: 1.0, maxScaleFactor: 1.3),
                          ),
                          child: Text(
                            R.string.contact.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.w700,
                              color: R.color.greenGradientBottom,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _buildProgramImage(),
                _buildCardWithButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        ProgramService.getProgramImageFull(widget.program.code),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCardWithButton() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            Utils.getBoxShadowDropCard(),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context)
                    .textScaler
                    .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
              ),
              child: Text(
                R.string.welcome_program.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: R.color.color0xff111515,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GapH(12),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context)
                    .textScaler
                    .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
              ),
              child: Text(
                widget.program.title.toUpperCase(),
                maxLines: 2,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GapH(24),
            _buildActivatedContent()
          ],
        ),
      ),
    );
  }
}
