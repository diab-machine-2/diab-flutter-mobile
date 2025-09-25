import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';

class BmiOnboardingCurrentHeightWidget extends StatelessWidget {
  const BmiOnboardingCurrentHeightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.chieuCao.tr(),
            style: R.style.largeTextStyle,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("00",
                  style: R.style.largeTextStyle.copyWith(
                      color: R.color.mainColor, fontWeight: FontWeight.w700)),
              Icon(
                Icons.edit_rounded,
                color: AppColors.neutral4,
              )
            ],
          ),
        ],
      ),
    );
  }
}
