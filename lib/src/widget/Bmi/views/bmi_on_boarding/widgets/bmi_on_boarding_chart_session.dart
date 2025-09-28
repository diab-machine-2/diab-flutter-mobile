import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/enum.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/widgets/bmi_ai_weight_index_analysis.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/widgets/bmi_date_filter_bar.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/widgets/bmi_statistical_chart.dart';

class BmiOnBoardingChartSession extends StatefulWidget {
  const BmiOnBoardingChartSession({
    super.key,
  });

  @override
  State<BmiOnBoardingChartSession> createState() =>
      _BmiOnBoardingChartSessionState();
}

class _BmiOnBoardingChartSessionState extends State<BmiOnBoardingChartSession> {
  final _gradientBg = LinearGradient(
    colors: [
      R.color.backgroundColorNew,
      Colors.white,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  late BmiBloc _bmiBloc;

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: _gradientBg),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          BmiDateFilterBar(
            onChanged: _onPeriodChanged,
          ),
          const SizedBox(
            height: 12,
          ),
          const _DateTimeLabel(),
          const SizedBox(
            height: 8,
          ),
          const _InfoHeader(),
          const BmiStatisticalChart(),
          const SizedBox(
            height: 8,
          ),
          const BmiAiWeightIndexAnalysis(),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  void _onPeriodChanged(BmiDateFilterType filterType) {
    _bmiBloc.changePeriodTime(filterType, isStatisticalView: true);
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) => state is BmiGetBmiStatisticalState,
        builder: (context, state) {
          return Column(
            children: [
              Text(
                bmiBloc.bmiStatistical?.bmiEvaluation ?? "--",
                style: R.style.boldXXLargeStyle
                    .copyWith(color: bmiBloc.bmiStatistical?.color),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "BMI ",
                    style: R.style.normalTextStyle.neutral4,
                  ),
                  Text(
                    "${bmiBloc.avgBmi ?? "--"}",
                    style: R.style.boldNormalStyle.neutral3,
                  ),
                  Text(
                    " \u2022 ",
                    style: R.style.boldLargeStyle.neutral4,
                  ),
                  Text(
                    "${bmiBloc.bmiStatistical?.weight ?? "--"}",
                    style: R.style.boldNormalStyle.neutral3,
                  ),
                  Text(
                    " kg",
                    style: R.style.normalTextStyle.neutral4,
                  ),
                ],
              )
            ],
          );
        });
  }
}

class _DateTimeLabel extends StatelessWidget {
  const _DateTimeLabel({
    super.key,
  });

  static const _timeFormat = Const.HOUR_MIN;
  static const _dateFormat = "dd/MM";

  @override
  Widget build(BuildContext context) {
    BmiBloc bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, state) => state is BmiGetBmiStatisticalState,
        builder: (context, state) {
          String time =
              DateFormat(_timeFormat).format(bmiBloc.selectedTimeOnChart!);
          String date =
              DateFormat(_dateFormat).format(bmiBloc.selectedTimeOnChart!);

          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50.0))),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Text(
              bmiBloc.selectedTimeOnChart != null ? "$time \u2022 $date" : "--",
              style: R.style.normalTextStyle.neutral3,
            ),
          );
        });
  }
}
