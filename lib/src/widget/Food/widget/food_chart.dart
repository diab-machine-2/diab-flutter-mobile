import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_diet_model.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';

import 'add_target_food.dart';

class FoodChart extends StatefulWidget {
  FoodChart({Key? key}) : super(key: key);
  @override
  FoodChartState createState() => FoodChartState();
}

class FoodChartState extends State<FoodChart>
    with AutomaticKeepAliveClientMixin<FoodChart> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;

  bool isEnergyTab = true;

  int touchIndex = -1;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticDetail(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodDietModel? model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticDetail(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticDetailLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.dinh_duong_da_nap_theo_ngay.tr(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 20),
                        (isEnergyTab
                                ? model.energyChart.length == 0
                                : model.carbChart.length == 0)
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                                    context: context,
                                    builder: (_) => AddTargetFood(
                                        goal: 23,
                                        callback: (number) {

                                        }),
                                  );
                                },
                                child: Image.asset(
                                  R.drawable.img_food_empty,
                                ),
                              )
                            : Container(
                                width: width,
                                decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 8,
                                        right: 16,
                                        bottom: 16,
                                        top: 16),
                                    child: Column(
                                      children: [
                                        buildChart(model),
                                        buildDescription(model)
                                      ],
                                    )))
                      ]),
                );
        }));
  }

  Widget buildDescription(FoodDietModel model) {
    List<Widget> items = [];
    model.legends.forEach((element) {
      items.add(buildDescriptionItem(element));
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: items);
  }

  Widget buildDescriptionItem(LegendModel model) {
    return Row(children: [
      Container(width: 14, height: 14, color: toColor(model.colorCode)),
      SizedBox(width: 4),
      Text(model.text!)
    ]);
  }

  // showDialog(BuildContext context) {
    //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
    // Navigator.of(context).push(PageRouteBuilder(
    //     opaque: false,
    //     pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  // }

  String getToolTips(FoodDietModel model) {
    final data = isEnergyTab
        ? model.energyChart[touchIndex]
        : model.carbChart[touchIndex];

    List<String> numbers = [];
    // double total = 0;
    // data.details.forEach((element) {
    //   total += element.value;
    // });
    data.details.forEach((element) {
      numbers.add(element.percentValue!.toStringAsFixed(1) + '%');
    });
    return '${R.string.total.tr()}: ${formatNumber(data.value)} ${isEnergyTab ? R.string.kcal.tr() : 'g'}\n' +
        numbers.join(' - ');
  }

  buildChart(FoodDietModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    final data = isEnergyTab ? model.energyChart : model.carbChart;

    // final maxValue = data
    //     .map<double>((e) => e.details
    //         .reduce((a, b) => EnergyItemModel(
    //             value: a.value + b.value, percentValue: 0, colorCode: ''))
    //         .value)
    //     .reduce(max)
    //     .round();
    // final jumpValue = (maxValue / 4).round();
    // final maxY = jumpValue * 4;
    // List<int> number = List.generate(5, (index) => (jumpValue * index).round())
    //     .reversed
    //     .toList();

    double minY = data
        .map<double>((e) =>
            (e.details.map<double>((element) => element.value ?? 0).reduce(min))).reduce(min);
    minY = (minY * (data.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = data.map<double>((e) => (e.value ?? 0)).reduce(max);
    maxY = (maxY * (data.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEnergyTab = true;
                });
              },
              child: Container(
                  height: 32,
                  width: 135,
                  padding: EdgeInsets.only(left: 18, right: 18),
                  decoration: BoxDecoration(
                      color:
                          isEnergyTab ? R.color.mainColor : R.color.transparent,
                      border: Border.all(
                          color: isEnergyTab
                              ? R.color.mainColor
                              : R.color.primaryGreyColor,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(R.string.nang_luong.tr(),
                        style: TextStyle(
                            color: isEnergyTab
                                ? R.color.white
                                : R.color.primaryGreyColor,
                            fontSize: 14,
                            fontWeight: isEnergyTab
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  )),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEnergyTab = false;
                });
              },
              child: Container(
                  height: 32,
                  width: 135,
                  decoration: BoxDecoration(
                      color:
                          isEnergyTab ? R.color.transparent : R.color.mainColor,
                      border: Border.all(
                          color: isEnergyTab
                              ? R.color.primaryGreyColor
                              : R.color.white,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(R.string.chat_bot_duong.tr(),
                        style: TextStyle(
                            color: isEnergyTab
                                ? R.color.primaryGreyColor
                                : R.color.white,
                            fontSize: 14,
                            fontWeight: isEnergyTab
                                ? FontWeight.w400
                                : FontWeight.w700)),
                  )),
            )
          ]),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 300,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(number.length, (index) {
                  return Text(formatNumber(number[index].toDouble()),
                      style: TextStyle(
                          fontSize: 14,
                          color: R.color.black,
                          fontWeight: FontWeight.normal));
                })),
          ),
          Expanded(
            child: SingleChildScrollView(
              reverse: (isEnergyTab
                      ? model.energyChart.length
                      : model.carbChart.length) >
                  1,
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
                                    width: (((isEnergyTab
                                                            ? model.energyChart
                                                                .length
                                                            : model.carbChart
                                                                .length) <
                                                        5
                                                    ? 5
                                                    : (isEnergyTab
                                                        ? model
                                                            .energyChart.length
                                                        : model.carbChart
                                                            .length)) *
                                                (width + 20))
                                            .toDouble() -
                                        36,
                                    color: R.color.grayComponentBorder,
                                  ),
                                )))),
                Container(
                    width: (((isEnergyTab
                                        ? model.energyChart.length
                                        : model.carbChart.length) <
                                    5
                                ? 5
                                : (isEnergyTab
                                    ? model.energyChart.length
                                    : model.carbChart.length)) *
                            (width + 20))
                        .toDouble(),
                    height: 300,
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: BarChart(
                      BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          //groupsSpace: 50,
                          maxY: maxY,
                          minY: minY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (FlTouchEvent event,
                                BarTouchResponse? barTouch) {
                              if (event is! FlLongPressEnd &&
                                  event is! FlPanEndEvent) {
                                final value =
                                    barTouch!.spot!.touchedBarGroupIndex;
                                setState(() {
                                  touchIndex = value.toInt();
                                });
                              } else {
                                touchIndex = -1;
                              }
                            },
                            touchTooltipData: BarTouchTooltipData(
                              fitInsideVertically: true,
                              fitInsideHorizontally: true,
                              tooltipBgColor: touchIndex == -1
                                  ? R.color.transparent
                                  : toColor(isEnergyTab
                                      ? model.energyChart[touchIndex].colorCode
                                      : model.carbChart[touchIndex].colorCode),
                              tooltipPadding: const EdgeInsets.only(
                                  left: 12, right: 12, top: 4, bottom: 0),
                              tooltipMargin: 22,
                              getTooltipItem: (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                return BarTooltipItem(
                                  getToolTips(model),
                                  TextStyle(
                                    color: R.color.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                              margin: 16,
                              reservedSize: -16,
                              showTitles: true,
                              getTextStyles: (context, value) => TextStyle(
                                  color: R.color.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                              getTitles: (double value) {
                                return convertToUTC(
                                    model.energyChart[value.toInt()].date!,
                                    'dd/MM');
                              },
                            ),
                            leftTitles: SideTitles(
                                showTitles: false,
                                getTextStyles: (context, value) => TextStyle(
                                    color: R.color.black, fontSize: 14)),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: List.generate(
                              isEnergyTab
                                  ? model.energyChart.length
                                  : model.carbChart.length, (index) {
                            return buildBarChartGroupData(
                                isEnergyTab
                                    ? model.energyChart[index]
                                    : model.carbChart[index],
                                index);
                          })),
                    )),
                SizedBox(height: 340)
              ]),
            ),
          )
        ]),
      ],
    );
  }

  BarChartGroupData buildBarChartGroupData(EnergyModel model, int index) {
    double totalValue = 0;
    return BarChartGroupData(
      x: index,
      // showingTooltipIndicators:
      //     index == model.energyChart.length - 1 ? [0] : [],
      //barsSpace: 60,
      barRods: [
        BarChartRodData(
            width: 20,
            borderRadius: BorderRadius.circular(0),
            y: model.value!,
            colors: [R.color.transparent],
            rodStackItems: List.generate(model.details.length, (idx) {
              final total = totalValue;
              totalValue += model.details[idx].value!;
              return BarChartRodStackItem(
                  total, totalValue, toColor(model.details[idx].colorCode));
            }))
      ],
    );
  }
}
