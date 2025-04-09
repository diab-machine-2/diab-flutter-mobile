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

  void _viewDetailId(String? id) {

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
                const SizedBox(height: 20),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: R.color.mainColor,
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
                          if (AppSettings.isUS) {
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

                // Thấp nhất / Trung bình / Cao nhất
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const SizedBox(width: 16),
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: () async {
                //           // TODO: 
                //           // _viewDetailId(model.highestId);
                //           // BloodSugarDetailTabbarController.of(context)
                //           //     ?.loadInputWithId(1, model.highestId);
                //         },
                //         child: Center(
                //           child: Column(
                //             mainAxisSize: MainAxisSize.min,
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               Text(
                //                 R.string.highest.tr(),
                //                 style: TextStyle(
                //                   color: R.color.textDark,
                //                   fontSize: 14,
                //                   height: 20 / 14,
                //                   fontWeight: FontWeight.w400,
                //                 ),
                //               ),
                //               const SizedBox(height: 3),
                //               Text(
                //                 model.highest == 0 ? '--' : roundNumber(model.highest!),
                //                 style: TextStyle(
                //                   fontSize: 20,
                //                   height: 24 / 20,
                //                   fontWeight: FontWeight.bold,
                //                   color: model.highest == 0
                //                       ? R.color.textDark
                //                       : Color(int.parse(
                //                           '0xff${model.highestColor!.split('#').join()}')),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //     SizedBox(width: 8),
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: () async {
                //           BloodSugarDetailTabbarController.of(context)
                //               ?.loadInputWithId(1, model.lowestId);
                //         },
                //         child: Center(
                //           child: Column(
                //             mainAxisSize: MainAxisSize.min,
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               Text(
                //                 R.string.medium.tr(),
                //                 style: TextStyle(
                //                   color: R.color.textDark,
                //                   fontSize: 14,
                //                   height: 20 / 14,
                //                   fontWeight: FontWeight.w400,
                //                 ),
                //               ),
                //               const SizedBox(height: 3),
                //               Text(
                //                 model.average == 0 ? '--' : roundNumber(model.average!),
                //                 style: TextStyle(
                //                   fontSize: 20,
                //                   height: 24 / 20,
                //                   fontWeight: FontWeight.bold,
                //                   color: model.average == 0
                //                       ? R.color.textDark
                //                       : Color(int.parse(
                //                           '0xff${model.averageColor!.split('#').join()}')),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //     SizedBox(width: 9),
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: () async {
                //           BloodSugarDetailTabbarController.of(context)
                //               ?.loadInputWithId(1, model.lowestId);
                //         },
                //         child: Center(
                //           child: Column(
                //             mainAxisSize: MainAxisSize.min,
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               Text(
                //                 R.string.lowest.tr(),
                //                 style: TextStyle(
                //                   color: R.color.textDark,
                //                   fontSize: 14,
                //                   height: 20 / 14,
                //                   fontWeight: FontWeight.w400,
                //                 ),
                //               ),
                //               const SizedBox(height: 3),
                //               Text(
                //                 model.lowest == 0 ? '--' : roundNumber(model.lowest!),
                //                 style: TextStyle(
                //                   fontSize: 20,
                //                   height: 24 / 20,
                //                   fontWeight: FontWeight.bold,
                //                   color: model.lowest == 0
                //                       ? R.color.textDark
                //                       : Color(int.parse(
                //                           '0xff${model.lowestColor!.split('#').join()}')),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 16),
                //   ],
                // ),
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

    const double radius = 80;

    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      // height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 12),
          // Chart "tần suất phân bổ"
          Expanded(
            child: Center(
              child: SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: double.infinity,
                    centerSpaceColor: Colors.transparent,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        print(pieTouchResponse);
                      },
                    ),
                    sections: List.generate(
                      5,
                      (i) {
                        const bool showTitle = false;
                        late final double value;
                        late final Color color;
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
                          showTitle: showTitle,
                          radius: radius,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Guide
          Column(
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
                    number: (model.increaseLevelThree! / total * 100).round().toString(),
                    text: R.string.grade_3_hypertension.tr(),
                  ),
                ),
              ),
              SizedBox(height: 4),
              InkWell(
                onTap: () => widget.onViewDetail(BloodPressureRangeType.high2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: CircleIndicator(
                    color: toColor(model.increaseLevelTwoColor),
                    number: (model.increaseLevelTwo! / total * 100).round().toString(),
                    text: R.string.grade_2_hypertension.tr(),
                  ),
                ),
              ),
              SizedBox(height: 4),
              InkWell(
                onTap: () => widget.onViewDetail(BloodPressureRangeType.high1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: CircleIndicator(
                    color: toColor(model.increaseLevelOneColor),
                    number: (model.increaseLevelOne! / total * 100).round().toString(),
                    text: R.string.grade_1_hypertension.tr(),
                  ),
                ),
              ),
              SizedBox(height: 4),
              InkWell(
                onTap: () => widget.onViewDetail(BloodPressureRangeType.normal_high),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: CircleIndicator(
                    color: toColor(model.preIncreaseColor),
                    number: (model.preIncrease! / total * 100).round().toString(),
                    text: R.string.normal_high.tr(),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: InkWell(
                  onTap: () => widget.onViewDetail(BloodPressureRangeType.normal),
                  child: CircleIndicator(
                    color: toColor(model.normalColor),
                    number: (model.normal! / total * 100).round().toString(),
                    text: R.string.normal.tr(),
                  ),
                ),
              ),
              SizedBox(height: 4),
              InkWell(
                onTap: () => widget.onViewDetail(BloodPressureRangeType.low),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: CircleIndicator(
                    color: toColor(model.lowColor),
                    number: (model.low! / total * 100).round().toString(),
                    text: R.string.low.tr(),
                  ),
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}
