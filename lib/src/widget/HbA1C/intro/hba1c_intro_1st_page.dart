import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/HbA1C/intro/widgets/hba1c_help_section.dart';
import 'package:medical/src/widget/HbA1C/intro/widgets/hba1c_knowledge_section.dart';
import 'package:medical/src/widget/HbA1C/hba1c_navigation_helper.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/HbA1C/hba1c_functions.dart';

class HbA1cIntro1stPage extends StatefulWidget {
  final String? goalId;
  const HbA1cIntro1stPage({Key? key, this.goalId}) : super(key: key);

  @override
  State<HbA1cIntro1stPage> createState() => _HbA1cIntro1stPageState();
}

class _HbA1cIntro1stPageState extends State<HbA1cIntro1stPage> {
  @override
  void initState() {
    super.initState();
    _firebaseSetup();
  }

  Future<void> _firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "hba1c_intro_1st_page",
      screenClass: "HbA1cIntro1stPage",
    );
  }

  void _navigateToGuide() {
    Navigator.of(context).pushNamed(NavigatorName.hba1c_intro_2nd_page);
  }

  void _navigateToHbA1cMain() async {
    await HbA1cNavigationHelper.completeOnboarding(context);
  }

  void _navigateToInputSelection() async {
    // Show input method selection modal
    await showHbA1cInputMethodModal(
      context,
      popPrevious: true, // Close intro page after selection
      goalId: widget.goalId,
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
        R.string.hba1c.tr(),
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
              onTap: _navigateToGuide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: R.color.white,
                      fontSize: 15,
                      fontFamily: R.font.sfpro,
                      letterSpacing: 0.4),
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
          _buildHelpSection(),
          const SizedBox(height: 16),
          _buildKnowledgeSection(),
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
            R.drawable.im_hba1c_intro,
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
                  "Theo dõi HbA1c giúp đánh giá đường huyết đại hạn, phát hiện nguy cơ tiểu đường, kiểm soát bệnh, điều chỉnh cuộc sống, giảm biến chứng và theo dõi hiệu quả điều trị mà không cần lấy máu thường xuyên để kiểm tra.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 24 / 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.primaryGreyColor,
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
                        "Nhập HbA1c",
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

  Widget _buildHelpSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: HbA1cHelpSection(),
    );
  }

  Widget _buildKnowledgeSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: HbA1cKnowledgeSection(),
    );
  }
}
