import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_compare.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

import '../blood_sugar_functions.dart';

class BloodSugarCompareChart extends StatefulWidget {
  BloodSugarCompareChart({Key? key}) : super(key: key);
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
        BloodSugarDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
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
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
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
          return model == null
              ? Container(
                  height: 530,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.only(left: 18, right: 18, bottom: 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(R.string.compare.tr(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Container(
                                height: 32,
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(200.0),
                                    border:
                                        Border.all(color: R.color.grayBorder)),
                                child: GestureDetector(
                                  onTap: () {
                                    showActionCompareFilter(context);
                                  },
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: [
                                          Text(name),
                                          SizedBox(width: 2),
                                          Image.asset(
                                              R.drawable.ic_chevron_down,
                                              width: 24,
                                              height: 24)
                                        ],
                                      )),
                                )),
                          ],
                        ),
                        SizedBox(height: 23),
                        model.length == 0
                            ? EmptyDataBox(
                                text: "chỉ số đường huyết",
                                onTap: () async {
                                  await TrackingManager.analytics.logEvent(
                                      name: 'cta_button_clicked',
                                      parameters: {
                                        "screen_name": 'kpi_glycemic',
                                        'cta_button_name': 'cta_add_glycemic_2',
                                      });
                                  if (AppSettings.isUS) {
                                    Navigator.pushNamed(context,
                                        NavigatorName.add_blood_sugar_new,
                                        arguments: {'type': 'input'});
                                  } else {
                                    BloodSugarFunctions.showModalAddData(
                                        context);
                                  }
                                  // BloodSugarFunctions.showModalAddData(context);
                                  // Navigator.pushNamed(
                                  //     context, NavigatorName.add_blood_sugar,
                                  //     arguments: {'type': 'input', 'id': null});
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: R.color.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: R.color.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: buildChart(model)),
                      ]),
                );
        }));
  }

  buildChart(List<ComparerModel> model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    double minY = model
        .map<double>((e) =>
            (e.postGlucose! < e.preGlucose! ? e.postGlucose! : e.preGlucose!))
        .reduce(min);
    minY = (minY * (model.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = model
        .map<double>((e) =>
            (e.postGlucose! > e.preGlucose! ? e.postGlucose! : e.preGlucose!))
        .reduce(max);
    maxY = (maxY * (model.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();

    return Padding(
      padding: EdgeInsets.only(top: 36, bottom: 18, right: 18, left: 8),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 30,
              height: 300,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(number.length, (index) {
                    return Text(number[index].toString(),
                        style: R.style.normalTextStyle);
                  })),
            ),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.horizontal,
                child: Stack(children: [
                  Container(
                      height: 300,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              number.length,
                              (index) => Padding(
                                    padding: EdgeInsets.only(
                                        left: 8, top: 8, bottom: 8),
                                    child: Container(
                                      height: 1,
                                      width: ((model.length < 5
                                                      ? 5
                                                      : model.length) *
                                                  (width + 20))
                                              .toDouble() -
                                          36,
                                      color: R.color.grayComponentBorder,
                                    ),
                                  )))),
                  Container(
                      width:
                          ((model.length < 5 ? 5 : model.length) * (width + 20))
                              .toDouble(),
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
                                tooltipPadding: const EdgeInsets.only(
                                    left: 12, right: 12, top: 4, bottom: 0),
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
                                        group.barRods.last.y
                                            .round()
                                            .toString() +
                                        (group.barRods.first.y <=
                                                group.barRods.last.y
                                            ? '\n ↑' +
                                                ((group.barRods.last.y -
                                                            group.barRods.first
                                                                .y)
                                                        .round())
                                                    .toString()
                                            : '\n ↓' +
                                                ((group.barRods.first.y -
                                                            group
                                                                .barRods.last.y)
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
                                  return convertToUTC(
                                          model[value.toInt()].date!, 'dd/MM') +
                                      (model[value.toInt()].description == null
                                          ? ''
                                          : '\n${model[value.toInt()].description}');
                                },
                              ),
                              leftTitles: SideTitles(
                                  showTitles: false,
                                  getTextStyles: (context, value) => TextStyle(
                                      color: R.color.black, fontSize: 14)),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            barGroups: List.generate(model.length, (index) {
                              return buildBarChartGroupData(model, index);
                            })),
                      ))
                ]),
              ),
            )
          ]),
          SizedBox(height: comparerType == 1 ? 56 : 36),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Row(children: [
              Container(width: 14, height: 14, color: R.color.mainColor),
              SizedBox(width: 8),
              Text(comparerType == 1
                  ? R.string.truoc_an.tr()
                  : R.string.truoc_tap_luyen.tr())
            ]),
            Row(children: [
              Container(width: 14, height: 14, color: R.color.yellow),
              SizedBox(width: 8),
              Text(comparerType == 1
                  ? R.string.sau_an.tr()
                  : R.string.sau_tap_luyen.tr())
            ])
          ]),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, NavigatorName.blood_sugar_compare_table,
                arguments: {
                  'model': model,
                  'title': name,
                  'comparerType': comparerType,
                  'periodFilterType': periodFilterType,
                }),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(R.string.xem_chi_tiet.tr(),
                  style: TextStyle(color: R.color.mainColor)),
              Image.asset(R.drawable.ic_arrow_right, width: 20, height: 20)
            ]),
          )
        ],
      ),
    );
  }

  BarChartGroupData buildBarChartGroupData(
      List<ComparerModel> model, int index) {
    return BarChartGroupData(
      x: index,
      //showingTooltipIndicators: index == model.hbA1Cs.length - 1 ? [0] : [],
      barsSpace: 4,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.circular(0),
          y: model[index].preGlucose!,
          colors: [toColor(model[index].preGlucoseColor)],
          width: 8,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.circular(0),
          y: model[index].postGlucose!,
          colors: [toColor(model[index].postGlucoseColor)],
          width: 8,
        )
      ],
    );
  }

  showDialog(BuildContext context) {
    //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  showActionCompareFilter(BuildContext context) {
    // setState(() {
    //   this.isChoose = !isChoose;
    // });
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => ActionListCompare(
            selectedIndex: comparerType,
            callback: (value, index) {
              if (value != null) {
                name = value;
                comparerType = index == 0 ? 1 : 2;
                reloadData(periodFilterType);
              }
            }));
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchComparerGlucose(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: 1,
        comparerType: comparerType.toString()));
  }
}
