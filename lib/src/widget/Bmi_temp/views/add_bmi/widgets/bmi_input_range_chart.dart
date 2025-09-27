import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_state.dart';

class BmiInputRangeChart extends StatelessWidget {
  const BmiInputRangeChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const bmiStatusColors = [
      AppColors.bmiUnderThresholdColor,
      AppColors.bmiNormalColor,
      AppColors.bmiOverThreshold1Color,
      AppColors.bmiOverThreshold2Color,
      AppColors.bmiOverThreshold3Color,
    ];
    const double chartHeight = 8.0;
    const widthOfThresholdValue = 48.0;

    return Column(
      children: [
        _BmiMarker(),
        const SizedBox(
          height: 12,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            height: chartHeight,
            width: double.maxFinite,
            child: Row(
                children: bmiStatusColors
                    .map((color) => Expanded(child: Container(color: color)))
                    .toList()),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: widthOfThresholdValue / 2),
            ...Const.bmiThreshold
                .map((e) => SizedBox(
                    width: widthOfThresholdValue,
                    child: Text(
                      "$e",
                      textAlign: TextAlign.center,
                      style: R.style.normalTextStyle.neutral3,
                    )))
                .toList(),
            const SizedBox(width: widthOfThresholdValue / 2),
          ],
        )
      ],
    );
  }
}

class _BmiMarker extends StatefulWidget {
  const _BmiMarker({
    super.key,
  });

  @override
  State<_BmiMarker> createState() => _BmiMarkerState();
}

class _BmiMarkerState extends State<_BmiMarker> {
  late BmiInputBloc _bmiInputBloc;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiInputBloc, BmiInputState>(
        buildWhen: (_, state) =>
            state is BmiInputDataChangedState &&
            state.event == BmiInputDataChangeEvent.weightChanged,
        builder: (context, state) {
          return Text(
            "${_bmiInputBloc.bmi}",
            style: R.style.boldNormalStyle.mainColor,
          );
        });
  }
}
