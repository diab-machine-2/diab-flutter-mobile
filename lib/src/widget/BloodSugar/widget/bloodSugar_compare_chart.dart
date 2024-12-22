import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';

class BloodSugarCompareChart extends StatefulWidget {
  BloodSugarCompareChart({Key? key, required this.periodFilterType}) : super(key: key);

  final int periodFilterType;

  @override
  BloodSugarCompareChartState createState() => BloodSugarCompareChartState();
}

class BloodSugarCompareChartState extends State<BloodSugarCompareChart>
    with AutomaticKeepAliveClientMixin<BloodSugarCompareChart> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 3;
  String name = R.string.before_and_after_eating.tr();
  int comparerType = 1;

  @override
  void initState() {
    periodFilterType =
        BloodSugarDetailTabbarController.of(context)?.periodFilterType ?? widget.periodFilterType;
    super.initState();
  }

  void _doViewDetail(List<ComparerModel> model) {
    // showActionCompareFilter(context);
    Navigator.pushNamed(context, NavigatorName.blood_sugar_compare_table, arguments: {
      'model': model,
      'title': name,
      'comparerType': comparerType,
      'periodFilterType': periodFilterType,
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<GlucoseBloc>(
      create: (context) => GlucoseBloc(),
      child: BlocBuilder<GlucoseBloc, GlucoseState>(
          builder: (BuildContext context, GlucoseState state) {
        currentContext = context;
        List<ComparerModel>? model;

        if (state is GlucoseInitial) {
          BlocProvider.of<GlucoseBloc>(context).add(FetchComparerGlucose(
              currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
              page: 1,
              comparerType: comparerType.toString()));
        }
        if (state is GlucoseError) {
          Message.showToastMessage(context, state.message);
        }
        if (state is GlucoseComparerLoaded) {
          model = state.listcomparer.reversed.toList();
        }
        if (model == null || model.isEmpty) {
          return SizedBox();
        }

        return Container(
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: R.color.gray_btn),
          ),
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      R.string.compare.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: R.color.dark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(R.drawable.ic_compare, width: 32, height: 32),
                    const Spacer(),
                    InkWell(
                      onTap: () => _doViewDetail(model!),
                      child: SizedBox(
                        width: 80,
                        height: 32,
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
                  ],
                ),
                SizedBox(height: 16),
                _buildChart(model),
              ]),
        );
      }),
    );
  }

  Widget _buildChart(List<ComparerModel> model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    double minY = model
        .map<double>((e) => (e.postGlucose! < e.preGlucose! ? e.postGlucose! : e.preGlucose!))
        .reduce(min);
    minY = (minY * (model.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = model
        .map<double>((e) => (e.postGlucose! > e.preGlucose! ? e.postGlucose! : e.preGlucose!))
        .reduce(max);
    maxY = (maxY * (model.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round()).reversed.toList();

    return Padding(
      padding: EdgeInsets.only(right: 18, left: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 300,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(number.length, (index) {
                      return Text(number[index].toString(), style: R.style.normalTextStyle);
                    })),
              ),
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  child: Stack(
                    children: [
                      Container(
                          height: 300,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  number.length,
                                  (index) => Padding(
                                        padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                                        child: Container(
                                          height: 1,
                                          width:
                                              ((model.length < 5 ? 5 : model.length) * (width + 20))
                                                      .toDouble() -
                                                  36,
                                          color: R.color.grayComponentBorder,
                                        ),
                                      )))),
                      Container(
                        width: ((model.length < 5 ? 5 : model.length) * (width + 20)).toDouble(),
                        height: 300,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY,
                            minY: minY,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: R.color.yellow,
                                tooltipPadding:
                                    const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 0),
                                tooltipMargin: 22,
                                fitInsideVertically: true,
                                fitInsideHorizontally: true,
                                getTooltipItem: (
                                  BarChartGroupData group,
                                  int groupIndex,
                                  BarChartRodData rod,
                                  int rodIndex,
                                ) {
                                  return BarTooltipItem(
                                    group.barRods.first.y.round().toString() +
                                        '/' +
                                        group.barRods.last.y.round().toString() +
                                        (group.barRods.first.y <= group.barRods.last.y
                                            ? '\n ↑' +
                                                ((group.barRods.last.y - group.barRods.first.y)
                                                        .round())
                                                    .toString()
                                            : '\n ↓' +
                                                ((group.barRods.first.y - group.barRods.last.y)
                                                        .round())
                                                    .toString()),
                                    TextStyle(
                                      color: R.color.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: SideTitles(showTitles: false),
                              topTitles: SideTitles(showTitles: false),
                              show: true,
                              bottomTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => TextStyle(
                                    color: R.color.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                                reservedSize: -16,
                                margin: 16,
                                getTitles: (double value) {
                                  return convertToUTC(model[value.toInt()].date!, 'dd/MM');
                                },
                              ),
                              leftTitles: SideTitles(
                                  showTitles: false,
                                  getTextStyles: (context, value) =>
                                      TextStyle(color: R.color.black, fontSize: 14)),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                              model.length,
                              (index) {
                                return buildBarChartGroupData(model, index);
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: R.color.mainColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(width: 8),
                Text(comparerType == 1 ? R.string.truoc_an.tr() : R.string.truoc_tap_luyen.tr())
              ]),
              Row(children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: R.color.yellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(width: 8),
                Text(comparerType == 1 ? R.string.sau_an.tr() : R.string.sau_tap_luyen.tr())
              ])
            ],
          ),
          // SizedBox(height: 16),
          // GestureDetector(
          //   onTap: () =>
          //       Navigator.pushNamed(context, NavigatorName.blood_sugar_compare_table, arguments: {
          //     'model': model,
          //     'title': name,
          //     'comparerType': comparerType,
          //     'periodFilterType': periodFilterType,
          //   }),
          //   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //     Text(R.string.xem_chi_tiet.tr(), style: TextStyle(color: R.color.mainColor)),
          //     Image.asset(R.drawable.ic_arrow_right, width: 20, height: 20)
          //   ]),
          // ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  BarChartGroupData buildBarChartGroupData(List<ComparerModel> model, int index) {
    return BarChartGroupData(
      x: index,
      //showingTooltipIndicators: index == model.hbA1Cs.length - 1 ? [0] : [],
      barsSpace: 4,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          y: model[index].preGlucose!,
          colors: [toColor(model[index].preGlucoseColor)],
          width: 8,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          y: model[index].postGlucose!,
          colors: [toColor(model[index].postGlucoseColor)],
          width: 8,
        )
      ],
    );
  }

  void showDialog(BuildContext context) {
    //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false, pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  // void showActionCompareFilter(BuildContext context) {
  //   // setState(() {
  //   //   this.isChoose = !isChoose;
  //   // });
  //   showModalBottomSheet(
  //       shape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
  //       backgroundColor: R.color.white,
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) => ActionListCompare(
  //           selectedIndex: comparerType,
  //           callback: (value, index) {
  //             if (value != null) {
  //               name = value;
  //               comparerType = index == 0 ? 1 : 2;
  //               reloadData(periodFilterType);
  //             }
  //           }));
  // }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchComparerGlucose(
        currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: 1,
        comparerType: comparerType.toString()));
  }
}
