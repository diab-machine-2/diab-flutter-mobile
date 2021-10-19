import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/expandable_rich_text.dart';

class BloodSugarSurveyEmpty extends StatelessWidget {
  const BloodSugarSurveyEmpty({required this.templateDetail});
  final BloodSugarTemplateResponseData? templateDetail;

  @override
  Widget build(BuildContext context) {
    final String description = templateDetail?.description ?? '';
    return Scaffold(
      body: CommonPage(
        title: R.string.result.tr(),
        background: R.drawable.bg_detail_pro,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(40.w, 50.h, 40.w, 50.h),
              child:
                  Image.asset(R.drawable.img_blood_sugar_survey_empty_result),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: RichText(
                textDirection: ui.TextDirection.ltr,
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: R.string.recommand_blood_sugar.tr(),
                  style: TextStyle(
                      color: R.color.primaryGreyColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' ${R.string.no_need_to_test.tr()} ',
                      style: TextStyle(
                          color: R.color.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp),
                    ),
                    TextSpan(
                      text: R.string.often_testing_blood_sugar.tr(),
                      style: TextStyle(
                          color: R.color.primaryGreyColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: description.isNotEmpty,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: R.color.main_6,
                    borderRadius: BorderRadius.circular(8)),
                child: ExpandableRichText(
                  description,
                  maxLines: 3,
                  trimExpandedText: R.string.show_less.tr(),
                  trimCollapsedText: R.string.show_more.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark,
                  ),
                  moreStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.greenGradientBottom,
                  ),
                  lessStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.greenGradientBottom,
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
            SafeArea(
              top: false,
              child: Container(
                width: 208.w,
                child: ButtonWidget(
                    title: R.string.back_to_schedule.tr(),
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(
                          NavigatorName.schedule_glucose,
                        ),
                      );
                    }),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
