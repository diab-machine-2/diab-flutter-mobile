import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_distribution.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_result.dto.dart';
import 'package:medical/src/widget/BloodSugar/blood_sugar_functions.dart';
import 'package:medical/src/widget/components/samples/pie_chart/samples/indicator.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

class BloodPressureDistributionChart extends StatefulWidget {
  BloodPressureDistributionChart({
    Key? key,
    required this.periodFilterType,
    required this.onViewMore,
    required this.onViewDetail,
  }) : super(key: key);

  final int periodFilterType;
  final Function() onViewMore;
  final Function(BloodPressureRangeType) onViewDetail;
  @override
  BloodPressureDistributionChartState createState() => BloodPressureDistributionChartState();
}

class BloodPressureDistributionChartState extends State<BloodPressureDistributionChart>
    with AutomaticKeepAliveClientMixin<BloodPressureDistributionChart> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  int selectedIndex = -1;

  int periodFilterType = 3;
  @override
  void initState() {
    periodFilterType = widget.periodFilterType;
    super.initState();
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<BloodPressureBloc>(currentContext).add(FetchDistributionBloodPressure(
      currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  void _doViewMore() {
    widget.onViewMore();
  }

  void _viewDetailId(String? id) {}

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
            BlocProvider.of<BloodPressureBloc>(context).add(FetchDistributionBloodPressure(
              currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is BloodPressureDistributionLoaded) {
            model = state.listDistribution;
          }

          if (model == null) {
            return Container(height: 240, child: Center(child: CircularProgressIndicator()));
          }
          return Container(
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: R.color.gray_btn, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Title
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          R.string.distribution_frequency.tr(),
                          style: TextStyle(
                            color: R.color.dark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _doViewMore,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: SizedBox(
                            width: 80,
                            height: 28,
                            child: Text(
                              R.string.show_more.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF95682E),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                (model.total ?? 0) == 0
                    ? EmptyDataBox(
                        text: "chỉ số huyết áp",
                        onTap: () async {
                          // await TrackingManager.analytics
                          //     .logEvent(name: 'cta_button_clicked', parameters: {
                          //   "screen_name": 'kpi_glycemic',
                          //   'cta_button_name': 'cta_add_glycemic_0',
                          // });
                          if (!AppSettings.isRegionAllowInputDevice) {
                            Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
                                arguments: {'type': 'input'});
                          } else {
                            BloodSugarFunctions.showModalAddData(context);
                          }
                        },
                      )
                    : _buildChart(model),

                const SizedBox(height: 16),
                Divider(
                  color: R.color.gray_btn,
                  thickness: 1,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 16),

                // Thấp nhất / Cao nhất
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (model?.lowestId != null) {
                            _viewDetailId(model!.lowestId);
                          }
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                R.string.lowest.tr(),
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (model.lowestId == null)
                                    ? '--'
                                    : '${model.lowestSystolic?.toInt() ?? 0}/${model.lowestDiastolic?.toInt() ?? 0}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: R.color.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (model?.highestId != null) {
                            _viewDetailId(model!.highestId);
                          }
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                R.string.highest.tr(),
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (model.highestId == null)
                                    ? '--'
                                    : '${model.highestSystolic?.toInt() ?? 0}/${model.highestDiastolic?.toInt() ?? 0}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: R.color.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }));
  }

  Widget _buildChart(BloodPressureDistributionModel model) {
    final total = model.increaseLevelThree! +
        model.increaseLevelTwo! +
        model.increaseLevelOne! +
        model.preIncrease! +
        model.normal! +
        model.low!;

    double fontsize = 12;

    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      // height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 12),
          // Chart "tần suất phân bổ"
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: 270,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                  centerSpaceColor: Colors.transparent,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                  sections: List.generate(
                    6,
                    (i) {
                      const bool showTitle = false;
                      late final double value;
                      late final Color color;
                      if (i == 0) {
                        // "Tăng huyết áp độ 3"
                        color = toColor(model.increaseLevelThreeColor);
                        value = model.increaseLevelThree! / total * 100;
                      } else if (i == 1) {
                        // "Tăng huyết áp độ 2"
                        color = toColor(model.increaseLevelTwoColor);
                        value = model.increaseLevelTwo! / total * 100;
                      } else if (i == 2) {
                        // "Tăng huyết áp độ 1"
                        color = toColor(model.increaseLevelOneColor);
                        value = model.increaseLevelOne! / total * 100;
                      } else if (i == 3) {
                        // "Bình thường cao"
                        color = toColor(model.preIncreaseColor);
                        value = model.preIncrease! / total * 100;
                      } else if (i == 4) {
                        // "Bình thường"
                        color = toColor(model.normalColor);
                        value = model.normal! / total * 100;
                      } else {
                        // "Thấp"
                        color = toColor(model.lowColor);
                        value = model.low! / total * 100;
                      }
                      return PieChartSectionData(
                        color: color,
                        value: value,
                        showTitle: true,
                        title: '${value.round()}%',
                        titleStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        radius: 45,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Guide
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () => widget.onViewDetail(BloodPressureRangeType.very_high),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: CircleIndicator(
                      color: toColor(model.increaseLevelThreeColor),
                      number: '', // (model.increaseLevelThree! / total * 100).round().toString(),
                      text: R.string.grade_3_hypertension.tr(),
                      fontsize: fontsize,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => widget.onViewDetail(BloodPressureRangeType.high2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: CircleIndicator(
                      color: toColor(model.increaseLevelTwoColor),
                      number: '', // (model.increaseLevelTwo! / total * 100).round().toString(),
                      text: R.string.grade_2_hypertension.tr(),
                      fontsize: fontsize,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => widget.onViewDetail(BloodPressureRangeType.high1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: CircleIndicator(
                      color: toColor(model.increaseLevelOneColor),
                      number: '', // (model.increaseLevelOne! / total * 100).round().toString(),
                      text: R.string.grade_1_hypertension.tr(),
                      fontsize: fontsize,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => widget.onViewDetail(BloodPressureRangeType.normal_high),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: CircleIndicator(
                      color: toColor(model.preIncreaseColor),
                      number: '', // (model.preIncrease! / total * 100).round().toString(),
                      text: R.string.normal_high.tr(),
                      fontsize: fontsize,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: InkWell(
                    onTap: () => widget.onViewDetail(BloodPressureRangeType.normal),
                    child: CircleIndicator(
                      color: toColor(model.normalColor),
                      number: '', // (model.normal! / total * 100).round().toString(),
                      text: R.string.normal.tr(),
                      fontsize: fontsize,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => widget.onViewDetail(BloodPressureRangeType.low),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: CircleIndicator(
                      color: toColor(model.lowColor),
                      number: '', // (model.low! / total * 100).round().toString(),
                      text: R.string.low.tr(),
                      fontsize: fontsize,
                    ),
                  ),
                ),
                SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
