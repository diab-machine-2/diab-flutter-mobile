import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class BloodSugarRecommandLayoutWidget extends StatelessWidget {
  const BloodSugarRecommandLayoutWidget({
    required this.title,
    required this.child,
    this.resultSurvey = '',
    this.onTapBack,
  });
  final String title;
  final Widget child;
  final String resultSurvey;
  final VoidCallback? onTapBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.color0xffF4DBBD,
      body: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: resultSurvey.isEmpty
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
                padding: const EdgeInsets.all(16.0),
                child: Row(children: [
                  Expanded(
                    child: RichText(
                      textDirection: ui.TextDirection.ltr,
                      text: TextSpan(
                        text: R.string.recommand_blood_sugar_test.tr(),
                        style: TextStyle(color: R.color.primaryGreyColor),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                R.string.time_per_day.tr(args: [resultSurvey]),
                            style: TextStyle(
                                color: R.color.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
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
    return Container(
      height: 100,
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: Text(title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: R.color.textDark)),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            if (onTapBack == null)
              Navigator.pop(context);
            else {
              onTapBack!.call();
            }
          },
        ),
      ),
    );
  }
}
