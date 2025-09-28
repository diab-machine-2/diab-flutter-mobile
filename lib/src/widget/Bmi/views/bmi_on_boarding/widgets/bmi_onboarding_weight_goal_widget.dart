import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';

class BmiOnboardingWeightGoalWidget extends StatelessWidget {
  const BmiOnboardingWeightGoalWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

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
            R.string.muc_tieu_can_nang.tr(),
            style: R.style.largeTextStyle,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_bmiBloc.weightGoal} kg",
                  style: R.style.largeTextStyle.copyWith(
                      color: R.color.mainColor, fontWeight: FontWeight.w700)),
              // Icon(
              //   Icons.edit_rounded,
              //   color: AppColors.neutral4,
              // )
            ],
          ),
        ],
      ),
    );
  }
}
