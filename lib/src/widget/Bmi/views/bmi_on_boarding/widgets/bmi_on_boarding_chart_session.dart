import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/res/generated/dimens.g.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/bmi/enum.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_date_filter_bar.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_statistical_chart.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

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
          _DateTimeLabel(),
          BmiStatisticalChart(),
          _AIAnalysic(),
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

class _AIAnalysic extends StatelessWidget {
  const _AIAnalysic({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) => current is BmiGetAIAnalysicState,
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    R.string.ai_suggestion_glucose.tr(),
                    style: R.style.semiBoldXLargeStyle,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Icon(Icons.info_outline_rounded)
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                _bmiBloc.aiAnalysicTrend,
                style: R.style.normalTextStyle,
              ),
              const SizedBox(
                height: 12,
              ),
              SecondaryRoundedButton(
                title: R.string.chat_with_AI.tr(),
                onPressed: () {},
              ),
            ],
          );
        });
  }
}

class _DateTimeLabel extends StatelessWidget {
  const _DateTimeLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50.0))),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      child: Text(
        "uio 9890",
        style: R.style.normalTextStyle,
      ),
    );
  }
}
