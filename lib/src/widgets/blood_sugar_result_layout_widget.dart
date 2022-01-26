import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class BloodSugarResultLayoutWidget extends StatelessWidget {
  const BloodSugarResultLayoutWidget({
    required this.title,
    required this.child,
    this.timeToTestPerDay,
    this.code,
    this.onTapBack,
  });
  final String title;
  final Widget child;
  final int? timeToTestPerDay;
  final String? code;
  final VoidCallback? onTapBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.color0xffF4DBBD,
      body: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: timeToTestPerDay == null ? _layoutWithShortAppBar(context) : _layoutWithTallAppBar(context),
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
                    R.drawable.img_blood_sugar_testing_schedule_tall,
                    fit: BoxFit.fitWidth,
                  ),
                  _buildAppBar(context),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                    child: RichText(
                      textDirection: ui.TextDirection.ltr,
                      text: TextSpan(
                        text: R.string.recommand_blood_sugar_test.tr(),
                        style: TextStyle(color: R.color.primaryGreyColor, fontWeight: FontWeight.w400, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                            text: code == 'K'
                                ? R.string.time_per_week.tr(args: ['$timeToTestPerDay'])
                                : R.string.time_per_day.tr(args: ['$timeToTestPerDay']),
                            style: TextStyle(color: R.color.black, fontWeight: FontWeight.w700, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 153)
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
        R.drawable.img_blood_sugar_testing_schedule_short,
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
        backgroundColor: R.color.transparent,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: R.color.textDark,
          ),
        ),
        leadingIcon: GestureDetector(
          onTap: onTapBack ??
              () {
                NavigationUtil.pop(context);
              },
          child: Icon(
            Icons.arrow_back,
            color: R.color.textDark,
          ),
        ),
      ),
    );
  }
}
