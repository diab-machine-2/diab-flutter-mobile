import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_distribution.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/blood_sugar_functions.dart';
import 'package:medical/src/widget/components/samples/pie_chart/samples/indicator.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

class BloodSugarDetail extends StatefulWidget {
  BloodSugarDetail({Key? key}) : super(key: key);
  @override
  BloodSugarDetailState createState() => BloodSugarDetailState();
}

class BloodSugarDetailState extends State<BloodSugarDetail>
    with AutomaticKeepAliveClientMixin<BloodSugarDetail> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;

  int periodFilterType = 3;
  @override
  void initState() {
    periodFilterType =
        BloodSugarDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) async {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchGlucoseDistribution(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: periodFilterType.toString()));
  }

  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<GlucoseBloc>(
        create: (context) => GlucoseBloc(),
        child: BlocBuilder<GlucoseBloc, GlucoseState>(
            builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          DistributionModel model;

          if (state is GlucoseInitial) {
            BlocProvider.of<GlucoseBloc>(context).add(FetchGlucoseDistribution(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: '1'));
          }
          if (state is GlucoseError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is GlucoseLoading) {
            return SizedBox();
          }
          if (state is GlucoseDistributionLoaded) {
            model = state.listDistribution;
            return Container(
              child: Column(
                children: [
                  Stack(children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 8, right: 8, top: 20, bottom: 12),
                      child: Column(children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      BloodSugarDetailTabbarController.of(
                                              context)!
                                          .loadInputWithId(1, model.lowestId);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 16,
                                          bottom: 16,
                                          left: 10,
                                          right: 10),
                                      decoration: BoxDecoration(
                                        color: R.color.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  model.lowest == 0
                                                      ? '--'
                                                      : roundNumber(
                                                          model.lowest!),
                                                  style: TextStyle(
                                                      fontFamily: 'Viga',
                                                      color: model.average == 0
                                                          ? R.color.textDark
                                                          : Color(int.parse(
                                                              '0xff${model.lowestColor!.split('#').join()}')),
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              SizedBox(width: 10),
                                              Image.asset(
                                                  R.drawable.ic_line_low,
                                                  width: 20,
                                                  height: 15)
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            R.string.lowest.tr(),
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 16,
                                        bottom: 16,
                                        left: 10,
                                        right: 10),
                                    decoration: BoxDecoration(
                                      color: R.color.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                model.average == 0
                                                    ? '--'
                                                    : roundNumber(
                                                        model.average!),
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    color: model.average == 0
                                                        ? R.color.textDark
                                                        : Color(int.parse(
                                                            '0xff${model.averageColor!.split('#').join()}')),
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            SizedBox(width: 10),
                                            Image.asset(
                                                R.drawable.ic_line_average,
                                                width: 20,
                                                height: 15)
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          R.string.medium.tr(),
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 15,
                                            // fontWeight: FontWeight.w700
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      BloodSugarDetailTabbarController.of(
                                              context)!
                                          .loadInputWithId(1, model.highestId);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 16,
                                          bottom: 16,
                                          left: 10,
                                          right: 10),
                                      decoration: BoxDecoration(
                                        color: R.color.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  model.highest == 0
                                                      ? '--'
                                                      : roundNumber(
                                                          model.highest!),
                                                  style: TextStyle(
                                                      fontFamily: 'Viga',
                                                      color: model.highest == 0
                                                          ? R.color.textDark
                                                          : Color(int.parse(
                                                              '0xff${model.highestColor!.split('#').join()}')),
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              SizedBox(width: 10),
                                              Image.asset(
                                                  R.drawable.ic_line_high,
                                                  width: 20,
                                                  height: 15)
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            R.string.highest.tr(),
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 15,
                                              // fontWeight: FontWeight.w700
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        SizedBox(height: 14),
                        Container(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(' ' + R.string.distribution_frequency.tr(),
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 15),
                            model.totalCount == 0
                                ? EmptyDataBox(
                                    text: "chỉ số đường huyết",
                                    onTap: () async {
                                      await TrackingManager.analytics.logEvent(
                                          name: 'cta_button_clicked',
                                          parameters: {
                                            "screen_name": 'kpi_glycemic',
                                            'cta_button_name':
                                                'cta_add_glycemic_0',
                                          });
                                      if (AppSettings.isUS) {
                                        Navigator.pushNamed(context,
                                            NavigatorName.add_blood_sugar_new,
                                            arguments: {'type': 'input'});
                                      } else {
                                        BloodSugarFunctions.showModalAddData(
                                            context);
                                      }
                                    },
                                  )
                                : buildChart(model)
                          ],
                        )),
                      ]),
                    ),
                  ]),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        }));
  }

  buildChart(DistributionModel model) {
    final total = model.veryHighCount! +
        model.highCount! +
        model.goodCount! +
        model.lowCount! +
        model.veryLowCount!;

    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Container(
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
                          centerSpaceRadius: (width / 4) / 2,
                          sections: List.generate(5, (i) {
                            const double radius = 28;
                            const bool showTitle = false;
                            late final double value;
                            late final Color color;
                            if (i == 0) {
                              color = toColor(model.veryHighColor);
                              value = model.veryHighCount! / total * 100;
                            } else if (i == 1) {
                              color = toColor(model.highColor);
                              value = model.highCount! / total * 100;
                            } else if (i == 2) {
                              color = toColor(model.goodColor);
                              value = model.goodCount! / total * 100;
                            } else if (i == 3) {
                              color = toColor(model.lowColor);
                              value = model.lowCount! / total * 100;
                            } else {
                              color = toColor(model.lowColor);
                              value = model.veryLowCount! / total * 100;
                            }
                            return PieChartSectionData(
                              color: color,
                              value: value,
                              showTitle: showTitle,
                              radius: radius,
                            );
                          })),
                    ))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    R.string.chu_thich.tr(),
                    style: TextStyle(fontSize: 14, color: R.color.textDark),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context,
                            NavigatorName.blood_sugar_distribution_table,
                            arguments: {
                              'title': R.string.very_high.tr(),
                              'glucoseDistributionType': 5,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.veryHighColor),
                        number: (model.veryHighCount! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.very_high.tr(),
                        textColor:
                            toColor(model.veryHighAttributesColor.fontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context,
                            NavigatorName.blood_sugar_distribution_table,
                            arguments: {
                              'title': R.string.high.tr(),
                              'glucoseDistributionType': 4,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.highColor),
                        number: (model.highCount! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.high.tr(),
                        textColor: toColor(model.highAttributesColor.fontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context,
                            NavigatorName.blood_sugar_distribution_table,
                            arguments: {
                              'title': R.string.good.tr(),
                              'glucoseDistributionType': 3,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.goodColor),
                        number: (model.goodCount! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.good.tr(),
                        textColor: toColor(model.goodAttributesColor.fontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context,
                            NavigatorName.blood_sugar_distribution_table,
                            arguments: {
                              'title': R.string.low.tr(),
                              'glucoseDistributionType': 2,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.lowColor),
                        number:
                            (model.lowCount! / total * 100).round().toString() +
                                '%',
                        text: R.string.low.tr(),
                        textColor: toColor(model.lowAttributesColor.fontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context,
                            NavigatorName.blood_sugar_distribution_table,
                            arguments: {
                              'title': R.string.very_low.tr(),
                              'glucoseDistributionType': 1,
                              'periodFilterType': periodFilterType
                            });
                      },
                      child: Indicator(
                        color: toColor(model.veryLowColor),
                        number: (model.veryLowCount! / total * 100)
                                .round()
                                .toString() +
                            '%',
                        text: R.string.very_low.tr(),
                        textColor:
                            toColor(model.veryLowAttributesColor.fontColor),
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }
}
