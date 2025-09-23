import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';

class BmiOnboardingAvarageBmiSession extends StatelessWidget {
  const BmiOnboardingAvarageBmiSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) => false,
        builder: (context, state) {
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
                  "ioiopaf",
                  style: R.style.alertTitle,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_bmiBloc.avgBmi}",
                      style: R.style.largeDisplayStyle,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.amber,
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
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(TextSpan(
                        text: "${R.string.highest.tr()}: ",
                        style: R.style.normalTextStyle,
                        children: [TextSpan(text: "${_bmiBloc.lowestBmi}")])),
                    Text.rich(TextSpan(
                        text: "${R.string.lowest.tr()}: ",
                        style: R.style.normalTextStyle,
                        children: [TextSpan(text: "${_bmiBloc.highestBmi}")]))
                  ],
                )
              ],
            ),
          );
        });
  }
}
