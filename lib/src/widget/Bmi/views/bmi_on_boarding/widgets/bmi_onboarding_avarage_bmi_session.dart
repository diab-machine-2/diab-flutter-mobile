import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/bmi/bmi_utils.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_threshold_bar_chart.dart';

class BmiOnboardingAvarageBmiSession extends StatelessWidget {
  const BmiOnboardingAvarageBmiSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) => state is BmiGetWeightStatisticalState,
        builder: (context, state) {
          Color thresholdColor =
              BmiUtils.getAvgBmiThresholdColor(_bmiBloc.avgBmi);

          return Container(
            decoration: R.decorationStyle.mediumRadiusCardStyles,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.string.averageBmi.tr(),
                  style: R.style.boldXLargeStyle,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_bmiBloc.avgBmi}",
                      style: R.style.largeDisplayStyle
                          .copyWith(color: thresholdColor),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: thresholdColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppDimens.smallRadius),
                            topRight: Radius.circular(AppDimens.smallRadius),
                            bottomLeft: Radius.circular(AppDimens.smallRadius),
                          )),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        "uiuoas",
                        style: R.style.normalTextStyle
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                BmiThresholdBarChart(
                  thresholds: Const.bmiThreshold,
                  colors: [
                    AppColors.bmiUnderThresholdColor,
                    AppColors.bmiNormalColor,
                    AppColors.bmiOverThreshold1Color,
                    AppColors.bmiOverThreshold2Color,
                    AppColors.bmiOverThreshold3Color,
                  ],
                  currentValue: 23,
                  markerWidget:
                      const Icon(Icons.arrow_drop_down, color: Colors.black),
                  barHeight: 24,
                  gap: 2,
                  borderRadius: 4,
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(TextSpan(
                        text: "${R.string.highest.tr()}: ",
                        style: R.style.normalTextStyle.neutral3,
                        children: [
                          TextSpan(
                            text: "${_bmiBloc.lowestBmi}",
                            style: R.style.boldNormalStyle,
                          )
                        ])),
                    Text.rich(TextSpan(
                        text: "${R.string.lowest.tr()}: ",
                        style: R.style.normalTextStyle.neutral3,
                        children: [
                          TextSpan(
                            text: "${_bmiBloc.highestBmi}",
                            style: R.style.boldNormalStyle,
                          )
                        ]))
                  ],
                )
              ],
            ),
          );
        });
  }
}
