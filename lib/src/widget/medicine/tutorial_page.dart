import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../res/R.dart';
import '../../app_setting/firebase_tracking/activity_list_tracking.dart';
import '../../utils/navigation_util.dart';
import '../../utils/navigator_name.dart';
import '../my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.color.backgroundColorNew,
      appBar: AppBar(
        leading: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Transform(
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              R.string.tutorial.tr(),
              style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        backgroundColor: R.color.transparent,
        //No more green
        elevation: 0.0,
        //Shadow gone
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [R.color.greenGradientMid, R.color.greenGradientBottom])),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNeedSupport(context),
            const SizedBox(height: 16),
            _buildShouldDoAndNotDo(),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedSupport(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          R.string.what_need_support.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: R.color.color0xff111515,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildNeedSupportItem(
                imageAsset: R.drawable.ic_mobile,
                text: R.string.use_schedule_medicine.tr(),
                onTap: () => _navigateToLessonDetail(context, '495c2864-6243-47b5-e5c1-08d9f1cbf93f', 1),
              ),
            ),
            const SizedBox(width: 11),
            Flexible(
              flex: 1,
              child: _buildNeedSupportItem(
                imageAsset: R.drawable.ic_medicine_calendar,
                text: R.string.why_schedule_medicine.tr(),
                onTap: () => _navigateToLessonDetail(context, 'c1bb1875-5d2e-43d3-6869-08d9ef854092', 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNeedSupportItem({required String imageAsset, required String text, Function? onTap}) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(imageAsset, width: 72, height: 72),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.color0xff111515,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShouldDoAndNotDo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.rule_safe_medicine.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(R.drawable.ic_should_do, width: 24,),
              const SizedBox(height: 1),
              Text(
                R.string.should_do.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff00830B,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildShouldDoItem(
            note: R.string.should_do_1.tr(),
            description: R.string.should_do_1_description.tr(),
          ),
          const SizedBox(height: 8),
          _buildShouldDoItem(
            note: R.string.should_do_2.tr(),
            description: R.string.should_do_2_description.tr(),
          ),
          const SizedBox(height: 8),
          _buildShouldDoItem(
            note: R.string.should_do_3.tr(),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(R.drawable.ic_should_not_do, width: 24,),
              const SizedBox(height: 1),
              Text(
                R.string.should_not_do.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff9C632B,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildShouldNotDoItem(
            note: R.string.should_not_do_1.tr(),
            description: R.string.should_not_do_1_description.tr(),
          ),
          const SizedBox(height: 8),
          _buildShouldNotDoItem(
            note: R.string.should_not_do_2.tr(),
          ),
          const SizedBox(height: 8),
          _buildShouldNotDoItem(
            note: R.string.should_not_do_3.tr(),
          ),

          const SizedBox(height: 16),
          Text(
            R.string.tutorial_reference.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: R.color.color0xffBFC6C6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShouldDoItem({required String note, String? description}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(0xFFEAFFEC),
        border: Border.all(color: const Color(0xFFC7F6D7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
          const SizedBox(height: 7),
          if (description != null) Text(
            description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff5E6566,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShouldNotDoItem({required String note, String? description}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(0xFFFFE9B3),
        border: Border.all(color: const Color(0xFFFFE9B3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
          const SizedBox(height: 7),
          if (description != null) Text(
            description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff5E6566,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLessonDetail(BuildContext context, String id, int type) async {
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
