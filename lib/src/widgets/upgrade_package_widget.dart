import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'button_widget.dart';

class UpgradePackageWidget extends StatelessWidget {
  final String? text;
  final VoidCallback onClickUpgrade;
  const UpgradePackageWidget({Key? key, required this.onClickUpgrade, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          R.drawable.img_upgrade_package,
          width: double.infinity,
          height: 240.h,
        ),
        SizedBox(
          height: 32.h,
        ),
        Text(
          text ?? R.string.text_upgrade_package.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16.sp,
            letterSpacing: 0.4,
            height: 1.375,
          ),
        ),
        SizedBox(
          height: 24.h,
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 40.h),
          child: ButtonWidget(
            title: R.string.upgrade_package_pro.tr(),
            // R.string.renewal_package_pro.tr(),
            onPressed: onClickUpgrade,
          ),
        ),
      ],
    );
  }
}
