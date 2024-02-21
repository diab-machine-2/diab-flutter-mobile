import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_distribution.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/components/samples/pie_chart/samples/indicator.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

class BloodPressureDistributionChart extends StatefulWidget {
  BloodPressureDistributionChart({Key? key}) : super(key: key);
  @override
  BloodPressureDistributionChartState createState() =>
      BloodPressureDistributionChartState();
}

class BloodPressureDistributionChartState
    extends State<BloodPressureDistributionChart>
    with AutomaticKeepAliveClientMixin<BloodPressureDistributionChart> {
  @override
  bool get wantKeepAlive => true;
  int periodFilterType = 1;
  late BuildContext currentContext;

  @override
  void initState() {
    periodFilterType =
        BloodPressureDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<BloodPressureBloc>(currentContext)
        .add(FetchDistributionBloodPressure(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<BloodPressureBloc>(
        create: (context) => BloodPressureBloc(),
        child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
            builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          BloodPressureDistributionModel? model;

          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context)
                .add(FetchDistributionBloodPressure(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is BloodPressureDistributionLoaded) {
            model = state.listDistribution;
          }
          return model == null
              ? Container(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  decoration: BoxDecoration(boxShadow: []),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(R.string.distribution_frequency.tr(),
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: model.total == 0
                            ? EmptyDataBox(
                                text: 'chỉ số huyết áp',
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, NavigatorName.add_blood_pressure,
                                      arguments: {'type': 'input', 'id': null});
                                },
                              )
                            : buildChart(model),
                      ),
                    ],
                  ),
                );
        }));
  }

  // final height = 37.0;

  buildChart(BloodPressureDistributionModel model) {
    final total = model.increaseLevelThree! +
        model.increaseLevelTwo! +
        model.increaseLevelOne! +
        model.preIncrease! +
        model.normal! +
        model.low!;

    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: R.color.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ], borderRadius: BorderRadius.circular(14), color: R.color.white),
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                    startDegreeOffset: 270,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: (width / 4) / 2 - 5,
                    sections: List.generate(6, (i) {
                      late final Color color;
                      late final value;
                      // const bool showTitle = false;
                      const double radius = 20;
                      if (i == 0) {
                        color = toColor(model.increaseLevelThreeColor);
                        value = model.increaseLevelThree! / total * 100;
                      } else if (i == 1) {
                        color = toColor(model.increaseLevelTwoColor);
                        value = model.increaseLevelTwo! / total * 100;
                      } else if (i == 2) {
                        color = toColor(model.increaseLevelOneColor);
                        value = model.increaseLevelOne! / total * 100;
                      } else if (i == 3) {
                        color = toColor(model.preIncreaseColor);
                        value = model.preIncrease! / total * 100;
                      } else if (i == 4) {
                        color = toColor(model.normalColor);
                        value = model.normal! / total * 100;
                      } else {
                        color = toColor(model.lowColor);
                        value = model.low! / total * 100;
                      }
                      return PieChartSectionData(
                        color: color,
                        value: value,
                        showTitle: false,
                        radius: radius,
                      );
                    })),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 4, left: 8, right: 8),
                child: Text(
                  R.string.chu_thich.tr(),
                  style: TextStyle(fontSize: 14, color: R.color.textDark),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.blood_pressure_table,
                            arguments: {
                              'title': R.string.grade_3_hypertension.tr(),
                              'bloodPressureType': 6,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.increaseLevelThreeColor),
                        number: (model.increaseLevelThree! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.grade_3_hypertension.tr(),
                        textColor: toColor(model.increaseLevelThreeFontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.blood_pressure_table,
                            arguments: {
                              'title': R.string.grade_2_hypertension.tr(),
                              'bloodPressureType': 5,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.increaseLevelTwoColor),
                        number: (model.increaseLevelTwo! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.grade_2_hypertension.tr(),
                        textColor: toColor(model.increaseLevelTwoFontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.blood_pressure_table,
                            arguments: {
                              'title': R.string.grade_1_hypertension.tr(),
                              'bloodPressureType': 4,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.increaseLevelOneColor),
                        number: (model.increaseLevelOne! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.grade_1_hypertension.tr(),
                        textColor: toColor(model.increaseLevelOneFontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.blood_pressure_table,
                            arguments: {
                              'title': R.string.normal_high.tr(),
                              'bloodPressureType': 3,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.preIncreaseColor),
                        number: (model.preIncrease! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.normal_high.tr(),
                        textColor: toColor(model.preIncreaseFontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.blood_pressure_table,
                            arguments: {
                              'title': R.string.normal.tr(),
                              'bloodPressureType': 2,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.normalColor),
                        number:
                            (model.normal! / total * 100).round().toString() +
                                '%',
                        text: R.string.normal.tr(),
                        //textColor: toColor(model.normalFontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.blood_pressure_table,
                            arguments: {
                              'title': R.string.low.tr(),
                              'bloodPressureType': 1,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.lowColor),
                        number:
                            (model.low! / total * 100).round().toString() + '%',
                        text: R.string.low.tr(),
                        textColor: toColor(model.lowFontColor),
                        isSquare: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
