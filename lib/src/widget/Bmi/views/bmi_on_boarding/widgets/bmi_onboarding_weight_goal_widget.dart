import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';

class BmiOnboardingWeightGoalWidget extends StatelessWidget {
  const BmiOnboardingWeightGoalWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) =>
            current is BmiUpdatedWeightGoalState ||
            (current is BmiDataChangedState &&
                current.event == BmiDataChangeEvent.weightGoalChanged),
        builder: (context, state) {
          return InkWell(
            onTap: () {
              // BmiGoalWeightInputDialog.show(
              //   context,
              //   currentGoal: _bmiBloc.weightGoal,
              //   onConfirmed: _bmiBloc.updateGoalWeight,
              // );
              Navigator.pushNamed(context, NavigatorName.goal_setting)
                  .then((value) {
                    _bmiBloc.updateGoalWeight();
                  });
            },
            child: Container(
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
                      Text("${_bmiBloc.weightGoal ?? "--"} kg",
                          style: R.style.largeTextStyle.copyWith(
                              color: R.color.mainColor,
                              fontWeight: FontWeight.w700)),
                      SvgPicture.asset(R.icons.ic_edit)
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
