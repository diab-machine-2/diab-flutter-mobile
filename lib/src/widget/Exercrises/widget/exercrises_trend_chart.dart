import 'dart:math';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../widgets/network_image_widget.dart';

class ExercrisesTrendChart extends StatefulWidget {
  ExercrisesTrendChart({Key? key}) : super(key: key);

  @override
  ExercrisesTrendChartState createState() => ExercrisesTrendChartState();
}

class ExercrisesTrendChartState extends State<ExercrisesTrendChart>
    with AutomaticKeepAliveClientMixin<ExercrisesTrendChart> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;

  int? touchIndex;

  @override
  void initState() {
    periodFilterType = ExercrisesDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchTimeTrend(
      currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          ExercriseTrendTimeModel? model;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchTimeTrend(
              currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is TimeTrendTrendLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(height: 491.5, child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.only(top: 30, bottom: 16, left: 16, right: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(R.string.xu_huong_thoi_gian.tr(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                                context: context,
                                builder: (_) => CustomInputTimePicker(
                                    title: periodFilterType == 1 || periodFilterType == 2
                                        ? R.string.so_phut_van_dong_moi_ngay.tr()
                                        : R.string.so_phut_van_dong_moi_tuan.tr(),
                                    time: 60,
                                    callback: (hour, minute) {
                                      submitTarget(hour * 60.0 + minute, null);
                                    }));
                          },
                          child: Container(
                            color: R.color.transparent,
                            child: Row(
                              children: [
                                Image.asset(
                                  R.drawable.ic_circle_plus_exe,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 4),
                                Text(R.string.muc_tieu_moi.tr(),
                                    style:
                                        TextStyle(color: R.color.mainColor, fontSize: 14, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 18, bottom: 16),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(R.string.tong_cong.tr(), style: R.style.normalTextStyle),
                                    Row(
                                      children: [
                                        Text('${(model.total! / 60).floor()}',
                                            style: TextStyle(
                                                fontFamily: 'Viga',
                                                color: R.color.textDark,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w400)),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0, left: 2, right: 2),
                                          child: Text(
                                            R.string.hour.tr(),
                                            style: R.style.normalTextStyle,
                                          ),
                                        ),
                                        Text(
                                            // 'abc',
                                            '${(model.total! - ((model.total! / 60).floor() * 60)).round()}',
                                            style: TextStyle(
                                                fontFamily: 'Viga',
                                                color: R.color.textDark,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w400)),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0, left: 2),
                                          child: Text(
                                            R.string.minute.tr(),
                                            style: R.style.normalTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(model.targetTitle ?? '', style: R.style.normalTextStyle),
                                    Row(
                                      children: [
                                        Text(model.target!.toInt().toString(),
                                            style: TextStyle(
                                                fontFamily: 'Viga',
                                                color: R.color.green,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w400)),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0, left: 2),
                                          child: Text(
                                            model.targetUnit ?? '',
                                            style: R.style.normalTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                            model.trendItems.items.length == 0
                                ? GestureDetector(
                                    onTap: () {
                                      if (AppSettings.userInfo!.weight == null || AppSettings.userInfo!.weight == 0) {
                                        showPopupWeight();
                                      } else {
                                        Navigator.pushNamed(context, NavigatorName.add_exercrises, arguments: {
                                          'type': 'input',
                                        });
                                      }
                                    },
                                    child: Image.asset(
                                      R.drawable.img_excerise_trend_empty,
                                    ),
                                  )
                                : Column(children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 8, right: 18, bottom: 0, top: 8),
                                        child: buildChart(model)),
                                    Padding(
                                      padding: EdgeInsets.only(top: 0, left: 16.0, bottom: 16),
                                      child: Row(
                                        children: [
                                          NetWorkImageWidget(imageUrl: 
                                            touchIndex == null
                                                ? model.trendItems.items[model.trendItems.items.length - 1]
                                                        .targetIconUrl!.url ??
                                                    ''
                                                : model.trendItems.items[touchIndex!].targetIconUrl!.url ?? '',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                              touchIndex == null
                                                  ? model.trendItems.items[model.trendItems.items.length - 1]
                                                      .targetDescription!
                                                  : model.trendItems.items[touchIndex!].targetDescription!,
                                              style: R.style.normalTextStyle),
                                        ],
                                      ),
                                    )
                                  ])
                          ],
                        )),
                    SizedBox(height: 16),
                    // buildDescription(model)
                  ]),
                );
        }));
  }

  // Widget buildDescription(ExercriseTrendTimeModel model) {
  //   return Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween, children: items);
  // }

  Widget buildDescriptionItem(List model) {
    final String color = model.last;
    final String title = model.first;
    return Row(children: [
      Container(width: 14, height: 14, color: Color(int.parse('0xff${color.split('#').join()}'))),
      SizedBox(width: 4),
      Text(title)
    ]);
  }

  // showDialog(BuildContext context) {
  //   //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
  //   Navigator.of(context).push(PageRouteBuilder(
  //       opaque: false,
  //       pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  // }

  buildChart(ExercriseTrendTimeModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    double minY = model.trendItems.items.map<double>((e) => e.duration ?? 0).reduce(min);
    minY = ((minY * (model.trendItems.items.length == 1 ? 0.5 : 0.8)).roundToDouble() / 60);
    double maxY = model.trendItems.items.map<double>((e) => e.duration ?? 0).reduce(max);
    maxY = ((maxY * (model.trendItems.items.length == 1 ? 1.5 : 1.2)).roundToDouble() / 60);
    final jumpValue = (maxY - minY) / 2;
    List<double> number = List.generate(3, (index) => roundAsFixed(jumpValue * index + minY)).reversed.toList();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36,
        height: 200,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(number.length, (index) {
              return Text(number[index].toString() + 'h',
                  style: TextStyle(fontSize: 14, color: R.color.black, fontWeight: FontWeight.normal));
            })),
      ),
      Expanded(
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Stack(children: [
            Container(
                height: 200,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                        number.length,
                        (index) => Padding(
                              padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                              child: Container(
                                height: 1,
                                width: ((model.trendItems.items.length < 5 ? 5 : model.trendItems.items.length) *
                                            (width + 20))
                                        .toDouble() -
                                    15,
                                color: R.color.grayComponentBorder,
                              ),
                            )))),
            Container(
                width:
                    ((model.trendItems.items.length < 5 ? 5 : model.trendItems.items.length) * (width + 20)).toDouble(),
                height: 200,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: BarChart(
                  BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: minY,
                      barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                              fitInsideVertically: true,
                              fitInsideHorizontally: true,
                              tooltipBgColor: touchIndex == null
                                  ? toColor(model.trendItems.items[model.trendItems.items.length - 1].targetColor)
                                  : toColor(model.trendItems.items[touchIndex!].targetColor),
                              maxContentWidth: 180,
                              tooltipPadding: const EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 8),
                              tooltipMargin: 8,
                              getTooltipItem: (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                if (model.trendItems.items[groupIndex].duration == 0 &&
                                    model.trendItems.items[groupIndex].burnedCalories == 0) {
                                  return null;
                                }
                                return BarTooltipItem(
                                  model.trendItems.items[groupIndex].duration!.round().toString() +
                                      'p • ' +
                                      model.trendItems.items[groupIndex].burnedCalories!.round().toString() +
                                      R.string.kcal.tr(),
                                  R.style.normalTextStyle,
                                );
                              }),
                          touchCallback: (FlTouchEvent event, BarTouchResponse? barTouch) {
                            if (event is! FlLongPressEnd && event is! FlPanEndEvent) {
                              final value = barTouch!.spot!.touchedBarGroupIndex;
                              touchIndex = value.toInt();
                            }
                            setState(() {});
                          }),
                      titlesData: FlTitlesData(
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: -16,
                          margin: 16,
                          getTextStyles: (context, value) =>
                              TextStyle(color: R.color.black, fontSize: 12, fontWeight: FontWeight.w400),
                          getTitles: (double value) {
                            if (model.trendItems.items[value.toInt()].firstDateOfWeek != null &&
                                model.trendItems.items[value.toInt()].lastDateOfWeek != null) {
                              return convertToUTC(model.trendItems.items[value.toInt()].firstDateOfWeek!, 'dd' + '-') +
                                  convertToUTC(model.trendItems.items[value.toInt()].lastDateOfWeek!, 'dd/MM');
                            }
                            return convertToUTC(model.trendItems.items[value.toInt()].date!, 'dd/MM');
                          },
                        ),
                        leftTitles: SideTitles(
                            showTitles: false,
                            getTextStyles: (context, value) =>
                                TextStyle(color: R.color.black, fontSize: 14, fontWeight: FontWeight.w400)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: List.generate(model.trendItems.items.length, (index) {
                        return buildBarChartGroupData(model, index);
                      })),
                )),
            maxY == 0 || (model.target! / 60) > maxY || (model.target! / 60) < minY
                ? SizedBox()
                : Container(
                    height: 200,
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Column(
                      children: [
                        SizedBox(height: (184 - (184 * (model.target! / 60 - minY) / (maxY - minY)))),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            color: R.color.color0xff72CB9C,
                            width:
                                ((model.trendItems.items.length < 5 ? 5 : model.trendItems.items.length) * (width + 20))
                                        .toDouble() -
                                    13,
                            height: 0.75,
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 240)
          ]),
        ),
      )
    ]);
  }

  BarChartGroupData buildBarChartGroupData(ExercriseTrendTimeModel model, int index) {
    // final color = toColor(model.trendItems.items[index].color);
    return BarChartGroupData(
      x: index,
      showingTooltipIndicators:
          touchIndex == index || (touchIndex == null && index == model.trendItems.items.length - 1) ? [0] : [],
      //barsSpace: 60,
      barRods: [
        BarChartRodData(
            width: 20,
            borderRadius: BorderRadius.circular(0),
            y: (model.trendItems.items[index].duration! / 60),
            colors: [toColor(model.trendItems.items[index].targetColor)]),
      ],
    );
  }

  // List<LineChartBarData> linesBarData(ExercriseTrendTimeModel model) {
  //   List<ExercriseTrendTimeModel> trends = [];
  //   // model.trendItems.items.forEach((item) {
  //   //   trends.addAll(item.subTrends);
  //   // });

  //   return trends.length == 0
  //       ? []
  //       : [
  //           LineChartBarData(
  //             spots: List.generate(trends.length, (index) {
  //               return FlSpot((index).toDouble(), trends[index].glucose);
  //             }),
  //             isCurved: false,
  //             colors:
  //                 trendTypeIndex == 1 ? [R.color.transparent] : [R.color.black],
  //             barWidth: 0.75,
  //             isStrokeCapRound: true,
  //             dotData: FlDotData(
  //                 show: true,
  //                 getDotPainter: (spot, percent, barData, index) {
  //                   return FlDotCirclePainter(
  //                     radius: 4,
  //                     color: toColor(trends[index].color),
  //                     strokeWidth: trends.length - 1 == index ? 18 : 0,
  //                     strokeColor: toColor(trends.last.color).withOpacity(0.2),
  //                   );
  //                 }),
  //             belowBarData: BarAreaData(
  //               show: false,
  //             ),
  //           )
  //         ];
  // }

  submitTarget(double time, String? exerciseCategoryId) async {
    try {
      BotToast.showLoading();
      await ExercrisesClient()
          .addExercriseTarget(periodFilterType == 1 || periodFilterType == 2 ? 1 : 2, 1, time, exerciseCategoryId);
      UserClient().fetchUser();
      Message.showToastMessage(context, R.string.them_muc_tieu_thanh_cong.tr());
      _refresh();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
