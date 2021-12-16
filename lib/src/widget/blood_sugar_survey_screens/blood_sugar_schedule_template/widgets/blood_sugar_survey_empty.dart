import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/expandable_rich_text.dart';

import '../../blood_sugar_start_survey/blood_sugar_start_survey.dart';

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
              padding: const EdgeInsets.fromLTRB(40, 50, 40, 50),
              child:
                  Image.asset(R.drawable.img_blood_sugar_survey_empty_result),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: RichText(
                textDirection: ui.TextDirection.ltr,
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: R.string.recommand_blood_sugar.tr(),
                  style: TextStyle(
                      color: R.color.primaryGreyColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' ${R.string.no_need_to_test.tr()} ',
                      style: TextStyle(
                          color: R.color.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: R.string.often_testing_blood_sugar.tr(),
                      style: TextStyle(
                          color: R.color.primaryGreyColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: description.isNotEmpty,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: R.color.main_6,
                    borderRadius: BorderRadius.circular(8)),
                child: ExpandableRichText(
                  description,
                  maxLines: 3,
                  trimExpandedText: R.string.show_less.tr(),
                  trimCollapsedText: R.string.show_more.tr(),
                  style: R.style.normalTextStyle,
                  moreStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: R.color.greenGradientBottom,
                  ),
                  lessStyle: TextStyle(
                    fontSize: 14,
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
                width: 208,
                child: ButtonWidget(
                    title: R.string.back_to_schedule.tr(),
                    onPressed: () {
                      NavigationUtil.popPassScreen(
                          context, BloodSugarStartSurveyPage);
                    }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
