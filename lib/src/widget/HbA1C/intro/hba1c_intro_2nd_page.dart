import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/HbA1C/intro/widgets/hba1c_help_section.dart';
import 'package:medical/src/widget/HbA1C/intro/widgets/hba1c_range_guide.dart';
import 'package:medical/src/widget/HbA1C/hba1c_navigation_helper.dart';

class HbA1cIntro2ndPage extends StatefulWidget {
  const HbA1cIntro2ndPage({Key? key}) : super(key: key);

  @override
  State<HbA1cIntro2ndPage> createState() => _HbA1cIntro2ndPageState();
}

class _HbA1cIntro2ndPageState extends State<HbA1cIntro2ndPage> {
  @override
  void initState() {
    super.initState();
    _firebaseSetup();
  }

  Future<void> _firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "hba1c_intro_2nd_page",
      screenClass: "HbA1cIntro2ndPage",
    );
  }

  void _navigateToHbA1cMain() async {
    await HbA1cNavigationHelper.completeOnboarding(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.white,
      appBar: CustomAppBar(
        backgroundColor: R.color.greenGradientBottom,
        title: Text(
          R.string.huong_dan.tr(),
          style: TextStyle(
            fontFamily: R.font.sfpro,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: R.color.white,
            letterSpacing: 0.2,
          ),
        ),
        leadingIcon: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              R.color.color0xFFFDC798.withOpacity(0.3),
              R.color.greenbg.withOpacity(0.3),
              R.color.greenbg.withOpacity(0.3),
              R.color.color0xFFFDC798.withOpacity(0.3),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.3, 0.8, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const HbA1cHelpSection(),
                    const SizedBox(height: 12),
                    const HbA1cRangeGuide(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
