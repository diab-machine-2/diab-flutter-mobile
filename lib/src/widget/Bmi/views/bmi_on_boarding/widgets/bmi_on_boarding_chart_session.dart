import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/enum.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/revise_weight_page.dart';
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
          _InfoHeader(),
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

// ignore: must_be_immutable
class _InfoHeader extends StatelessWidget {
  _InfoHeader({
    super.key,
  });

  late BmiBloc bmiBloc;

  @override
  Widget build(BuildContext context) {
    bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) =>
            state is BmiGetWeightIndexListState ||
            (state is BmiDataChangedState &&
                state.event == BmiDataChangeEvent.selectedPointChanged),
        builder: (context, state) {
          return Column(
            children: [
              if (bmiBloc.selectedPointChart?.bmiText != null)
                GestureDetector(
                  onTap: () => _redirectToDetail(context),
                  child: Text(
                    bmiBloc.selectedPointChart?.bmiText ?? "--",
                    style: R.style.boldXXLargeStyle.copyWith(
                      color: bmiBloc.selectedPointChart?.bmiBgColor,
                    ),
                  ),
                ),
              // const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      bmiBloc.backToPreviousPoint();
                    },
                    icon: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                              )
                            ]),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: bmiBloc.selectedPointChart == null
                              ? AppColors.neutral5
                              : AppColors.neutral3,
                          size: 18,
                        )),
                  ),
                  if (bmiBloc.selectedPointChart?.bmiText == null) ...[
                    Text(
                      R.string.no_data_within
                          .tr(args: ["${bmiBloc.periodType.days}"]),
                      textAlign: TextAlign.center,
                      style: R.style.normalTextStyle,
                    )
                  ] else ...[
                    GestureDetector(
                      onTap: () => _redirectToDetail(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "BMI ",
                            style: R.style.normalTextStyle.neutral4,
                          ),
                          Text(
                            "${bmiBloc.selectedPointChart?.bmi ?? "--"}",
                            style: R.style.boldNormalStyle.neutral3,
                          ),
                          Text(
                            " \u2022 ",
                            style: R.style.boldLargeStyle.neutral4,
                          ),
                          Text(
                            _getWeight(bmiBloc.selectedPointChart?.weight),
                            style: R.style.boldNormalStyle.neutral3,
                          ),
                          Text(
                            " kg",
                            style: R.style.normalTextStyle.neutral4,
                          ),
                        ],
                      ),
                    ),
                  ],
                  IconButton(
                    onPressed: () {
                      bmiBloc.goToNextPoint();
                    },
                    icon: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                              )
                            ]),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: bmiBloc.selectedPointChart == null
                              ? AppColors.neutral5
                              : AppColors.neutral3,
                          size: 18,
                        )),
                  ),
                ],
              )
            ],
          );
        });
  }

  String _getWeight(double? value) {
    if (value == null) return "--";
    bool isInteger = value.floor().toDouble() == value;
    if (isInteger) {
      return "${value.floor()}";
    }
    return value.toStringAsFixed(1);
  }

  void _redirectToDetail(BuildContext context) async {
    final updateResult = await Navigator.pushNamed(
      context,
      NavigatorName.bmiReviseRecordPage,
      arguments: {
        ReviseWeightPage.bmiBlocKey: bmiBloc,
        ReviseWeightPage.dataKey: bmiBloc.selectedPointChart,
      },
    );

    if (updateResult == true) {
      bmiBloc
        ..fetchHistoricalWeight()
        ..refresh();
    }
  }
}

class _DateTimeLabel extends StatelessWidget {
  const _DateTimeLabel({
    super.key,
  });

  static const _timeFormat = "HH:mm";
  static const _dateFormat = "dd/MM";

  @override
  Widget build(BuildContext context) {
    BmiBloc bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, state) =>
            state is BmiGetWeightIndexListState ||
            (state is BmiDataChangedState &&
                state.event == BmiDataChangeEvent.selectedPointChanged),
        builder: (context, state) {
          if (bmiBloc.selectedPointChart == null) {
            return const SizedBox();
          }

          DateTime datePoint = DateTime.fromMillisecondsSinceEpoch(
              bmiBloc.selectedPointChart!.date! * 1000);
          String time = DateFormat(_timeFormat).format(datePoint);
          String date = DateFormat(_dateFormat).format(datePoint);

          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50.0))),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Text(
              bmiBloc.selectedPointChart != null ? "$time \u2022 $date" : "--",
              style: R.style.normalTextStyle.neutral3,
            ),
          );
        });
  }
}
