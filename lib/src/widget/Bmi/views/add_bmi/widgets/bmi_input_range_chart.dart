import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';

class BmiInputRangeChart extends StatelessWidget {
  const BmiInputRangeChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

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
                children: _bmiBloc.weightThreshold
                    .map((threshold) => Expanded(
                        child: Container(
                            color: Utils.parseStringToColor(
                                threshold.backgroundColorCode))))
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
                      style: R.style.normalTextStyle.neutral4,
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
          return Text.rich(
            TextSpan(
                text: "BMI ",
                style: R.style.normalTextStyle.neutral4,
                children: [
                  TextSpan(
                    text: "${_bmiInputBloc.bmi}",
                    style: R.style.boldNormalStyle.mainColor,
                  )
                ]),
          );
        });
  }
}
