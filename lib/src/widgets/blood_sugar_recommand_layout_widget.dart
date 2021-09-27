import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/custom_app_bar.dart';

class BloodSugarRecommandLayoutWidget extends StatelessWidget {
  const BloodSugarRecommandLayoutWidget({
    required this.title,
    required this.child,
    this.timeToTestPerDay,
    this.onTapBack,
  });
  final String title;
  final Widget child;
  final int? timeToTestPerDay;
  final VoidCallback? onTapBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.color0xffF4DBBD,
      body: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: timeToTestPerDay == null
            ? _layoutWithShortAppBar(context)
            : _layoutWithTallAppBar(context),
      ),
    );
  }

  List<Widget> _layoutWithTallAppBar(BuildContext context) {
    return [
      Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Stack(
                children: [
                  Image.asset(
                    R.drawable.im_blood_sugar_testing_schedule_tall,
                    fit: BoxFit.fitWidth,
                  ),
                  _buildAppBar(context),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(children: [
                  Expanded(
                    child: timeToTestPerDay == 0
                        ? RichText(
                            textDirection: ui.TextDirection.ltr,
                            text: TextSpan(
                              text: R.string.recommand_blood_sugar_test.tr(),
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
                          )
                        : RichText(
                            textDirection: ui.TextDirection.ltr,
                            text: TextSpan(
                              text: R.string.recommand_blood_sugar_test.tr(),
                              style: TextStyle(
                                      color: R.color.primaryGreyColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.sp),
                              children: <TextSpan>[
                                TextSpan(
                                  text: R.string.time_per_day
                                      .tr(args: ['$timeToTestPerDay']),
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp),
                                )
                              ],
                            ),
                          ),
                  ),
                  SizedBox(width: 153.w)
                ]),
              ),
            ],
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    ];
  }

  List<Widget> _layoutWithShortAppBar(BuildContext context) {
    return [
      Image.asset(
        R.drawable.im_blood_sugar_testing_schedule_short,
        fit: BoxFit.fitWidth,
      ),
      Column(
        children: [
          Stack(
            children: [
              _buildAppBar(context),
            ],
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    ];
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: CustomAppBar(
        title: title,
        backCallback: () {
          if (onTapBack == null)
            NavigationUtil.pop(context);
          else {
            onTapBack!.call();
          }
        },
      ),
    );
  }
}
