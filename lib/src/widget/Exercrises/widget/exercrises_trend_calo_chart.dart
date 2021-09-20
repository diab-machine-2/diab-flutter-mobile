import 'dart:math';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_calo.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';

class ExercrisesTrendCaloChart extends StatefulWidget {
  ExercrisesTrendCaloChart({Key key}) : super(key: key);

  @override
  ExercrisesTrendCaloChartState createState() =>
      ExercrisesTrendCaloChartState();
}

class ExercrisesTrendCaloChartState extends State<ExercrisesTrendCaloChart>
    with AutomaticKeepAliveClientMixin<ExercrisesTrendCaloChart> {
  @override
  bool get wantKeepAlive => true;
  BuildContext currentContext;
  int periodFilterType = 1;

  int touchIndex;

  @override
  void initState() {
    periodFilterType =
        ExercrisesDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchCaloTrend(
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
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
            builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          ExercriseTrendCaloModel model;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchCaloTrend(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is CaloTrendLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Xu hướng đốt calo',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    barrierColor:
                                        R.color.color0xff003F38.withOpacity(0.5),
                                    context: context,
                                    builder: (_) => InputCalo(
                                        title: periodFilterType == 1 ||
                                                periodFilterType == 2
                                            ? 'Năng lượng đốt cháy / ngày'
                                            : 'Năng lượng đốt cháy / tuần',
                                        callback: (number) {
                                          submitTarget(double.parse(number));
                                        }));
                              },
                              child: Container(
                                color: R.color.transparent,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      R.drawable.circle_plus_exe,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 4),
                                    Text('Mục tiêu mới',
                                        style: TextStyle(
                                            color: R.color.mainColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
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
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Tổng cộng',
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.0)),
                                            Row(
                                              children: [
                                                Text(formatNumber(model.total),
                                                    style: TextStyle(
                                                        fontFamily: 'Viga',
                                                        color: R.color.textDark,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6.0, left: 2),
                                                  child: Text(
                                                    'kcal',
                                                    style: TextStyle(
                                                        color: R.color.textDark,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14.0),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(model.targetTitle ?? '',
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.0)),
                                            Row(
                                              children: [
                                                Text(
                                                    model.target
                                                        .toInt()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontFamily: 'Viga',
                                                        color: R.color.green,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6.0, left: 2),
                                                  child: Text(
                                                    model.targetUnit ?? '',
                                                    style: TextStyle(
                                                        color: R.color.textDark,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14.0),
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
                                          if (AppSettings.userInfo.weight ==
                                                  null ||
                                              AppSettings.userInfo.weight ==
                                                  0) {
                                            showPopupWeight();
                                          } else {
                                            Navigator.pushNamed(
                                                context, NavigatorName.add_exercrises,
                                                arguments: {
                                                  'type': 'input',
                                                });
                                          }
                                        },
                                        child: Image.asset(
                                          R.drawable.im_excerise_calo_empty,
                                          fit: BoxFit.cover,
                                        ))
                                    : Column(children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 8,
                                                right: 18,
                                                bottom: 0,
                                                top: 8),
                                            child: buildChart(model)),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, left: 16.0, bottom: 16),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                touchIndex == null
                                                    ? model
                                                            .trendItems
                                                            .items[model
                                                                    .trendItems
                                                                    .items
                                                                    .length -
                                                                1]
                                                            .targetIconUrl
                                                            .url ??
                                                        ''
                                                    : model
                                                            .trendItems
                                                            .items[touchIndex]
                                                            .targetIconUrl
                                                            .url ??
                                                        '',
                                                width: 24,
                                                height: 24,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                  touchIndex == null
                                                      ? model
                                                          .trendItems
                                                          .items[model
                                                                  .trendItems
                                                                  .items
                                                                  .length -
                                                              1]
                                                          .targetDescription
                                                      : model
                                                          .trendItems
                                                          .items[touchIndex]
                                                          .targetDescription,
                                                  style: TextStyle(
                                                      color: R.color.textDark,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0))
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

  submitTarget(double time) async {
    try {
      BotToast.showLoading();
      await ExercrisesClient().addExercriseTarget(
          periodFilterType == 1 || periodFilterType == 2 ? 1 : 2,
          2,
          time,
          null);
      await UserClient().fetchUser();
      Message.showToastMessage(context, 'Thêm mục tiêu thành công');
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

  Widget buildDescription(ExercriseTrendCaloModel model) {
    // List<Widget> items = [];
    // model.trendItems.items.forEach((element) {
    //   items.add(buildDescriptionItem(element));
    // });
    return Container(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween, children: items);
        child: Text('abc'));
  }

  Widget buildDescriptionItem(List model) {
    final String color = model.last;
    final String title = model.first;
    return Row(children: [
      Container(
          width: 14,
          height: 14,
          color: Color(int.parse('0xff${color.split('#').join()}'))),
      SizedBox(width: 4),
      Text(title)
    ]);
  }

  showTable(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  buildChart(ExercriseTrendCaloModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    double minY =
        model.trendItems.items.map<double>((e) => e.burnedCalories).reduce(min);
    minY = (minY * (model.trendItems.items.length == 1 ? 0.5 : 0.8))
        .roundToDouble();
    double maxY =
        model.trendItems.items.map<double>((e) => e.burnedCalories).reduce(max);
    maxY = (maxY * (model.trendItems.items.length == 1 ? 1.5 : 1.2))
        .roundToDouble();
    final jumpValue = (maxY - minY) / 2;
    List<double> number =
        List.generate(3, (index) => roundAsFixed(jumpValue * index + minY))
            .reversed
            .toList();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36,
        height: 200,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(number.length, (index) {
              return Text(formatNumber(number[index]),
                  style: TextStyle(
                      fontSize: 14,
                      color: R.color.black,
                      fontWeight: FontWeight.normal));
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
                              padding:
                                  EdgeInsets.only(left: 8, top: 8, bottom: 8),
                              child: Container(
                                height: 1,
                                width: ((model.trendItems.items.length < 5
                                                ? 5
                                                : model
                                                    .trendItems.items.length) *
                                            (width + 20))
                                        .toDouble() -
                                    36,
                                color: R.color.grayComponentBorder,
                              ),
                            )))),
            Container(
                width: ((model.trendItems.items.length < 5
                            ? 5
                            : model.trendItems.items.length) *
                        (width + 20))
                    .toDouble(),
                height: 200,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: BarChart(
                  BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      //groupsSpace: 50,
                      maxY: maxY,
                      minY: minY,
                      barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            tooltipBgColor: touchIndex == null
                                ? toColor(model
                                    .trendItems
                                    .items[model.trendItems.items.length - 1]
                                    .targetColor)
                                : toColor(model
                                    .trendItems.items[touchIndex].targetColor),
                            tooltipPadding: const EdgeInsets.only(
                                top: 8, bottom: 4, left: 8, right: 8),
                            tooltipMargin: 8,
                            getTooltipItem: (
                              BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex,
                            ) {
                              if (model.trendItems.items[groupIndex]
                                      .burnedCalories ==
                                  0) {
                                return null;
                              }
                              return BarTooltipItem(
                                model.trendItems.items[groupIndex]
                                        .burnedCalories
                                        .round()
                                        .toString() +
                                    ' kcal',
                                TextStyle(
                                    color: R.color.textDark,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              );
                            },
                          ),
                          touchCallback: (FlTouchEvent event, BarTouchResponse barTouch) {
                            if (event is! FlLongPressEnd &&
                                event is! FlPanEndEvent) {
                              final value = barTouch.spot.touchedBarGroupIndex;
                              touchIndex = value.toInt();
                            }
                            setState(() {});
                          }),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          margin: 16,
                          reservedSize: -16,
                          getTextStyles: (context, value) => TextStyle(
                              color: R.color.black,
                              fontSize: 10,
                              fontWeight: FontWeight.normal),
                          //margin: 10,
                          getTitles: (double value) {
                            if (model.trendItems.items[value.toInt()]
                                        .firstDateOfWeek !=
                                    null &&
                                model.trendItems.items[value.toInt()]
                                        .lastDateOfWeek !=
                                    null) {
                              return convertToUTC(
                                      model.trendItems.items[value.toInt()]
                                          .firstDateOfWeek,
                                      'dd' + '-') +
                                  convertToUTC(
                                      model.trendItems.items[value.toInt()]
                                          .lastDateOfWeek,
                                      'dd/MM');
                            }
                            return convertToUTC(
                                model.trendItems.items[value.toInt()].date,
                                'dd/MM');
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                          getTextStyles: (context, value) => TextStyle(
                              color: R.color.black, fontSize: 14),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups:
                          List.generate(model.trendItems.items.length, (index) {
                        return buildBarChartGroupData(model, index);
                      })),
                )),
            maxY == 0 || model.target > maxY || model.target < minY
                ? SizedBox()
                : Container(
                    height: 200,
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Column(
                      children: [
                        SizedBox(
                            height: (184 -
                                (184 * (model.target - minY) / (maxY - minY)))),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            color: R.color.color0xff72CB9C,
                            width: ((model.trendItems.items.length < 5
                                            ? 5
                                            : model.trendItems.items.length) *
                                        (width + 20))
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
      ),
    ]);
  }

  BarChartGroupData buildBarChartGroupData(
      ExercriseTrendCaloModel model, int index) {
    // final color = toColor(model.trendItems.items[index].color);
    return BarChartGroupData(
      x: index,
      showingTooltipIndicators: touchIndex == index ||
              (touchIndex == null && index == model.trendItems.items.length - 1)
          ? [0]
          : [],
      //barsSpace: 60,
      barRods: [
        BarChartRodData(
            width: 20,
            borderRadius: BorderRadius.circular(0),
            y: model.trendItems.items[index].burnedCalories,
            colors: [toColor(model.trendItems.items[index].targetColor)]),
      ],
    );
  }

  // List<LineChartBarData> linesBarData(TrendModel model) {
  //   final LineChartBarData lineChartBarData1 = LineChartBarData(
  //     spots: List.generate(model.trendItems.items.length, (index) {
  //       return FlSpot(
  //           (index + 0.5).toDouble(), model.trendItems.items[index].hbA1C);
  //     }),
  //     isCurved: false,
  //     colors: [R.color.black],
  //     barWidth: 1,
  //     isStrokeCapRound: true,
  //     dotData: FlDotData(
  //         show: true,
  //         checkToShowDot: (spot, barData) {
  //           return spot.x == model.trendItems.items.length - 0.5;
  //         },
  //         getDotPainter: (spot, percent, barData, index) {
  //           return FlDotCirclePainter(
  //             radius: 6,
  //             color: Color(0xffF44336),
  //             strokeWidth: 12,
  //             strokeColor: Color(0xffF44336).withOpacity(0.2),
  //           );
  //         }),
  //     belowBarData: BarAreaData(
  //       show: false,
  //     ),
  //   );

  //   return [
  //     lineChartBarData1,
  //   ];
  // }
}

typedef CaloCallback = Function(String);

class InputCalo extends StatefulWidget {
  final String title;
  final CaloCallback callback;
  InputCalo({@required this.title, this.callback});
  @override
  _InputCaloState createState() => _InputCaloState();
}

class _InputCaloState extends State<InputCalo> {
  TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        IconButton(
                            // padding: EdgeInsets.only(right: 30),
                            icon: Icon(Icons.close, color: R.color.grey),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(children: [
                      SizedBox(
                        width: 92,
                        child: CupertinoTextField(
                            enableInteractiveSelection: false,
                            controller: textEditingController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[-]'))
                            ],
                            maxLength: 5,
                            decoration:
                                BoxDecoration(color: R.color.transparent),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                            placeholder: '--',
                            placeholderStyle: TextStyle(
                                color: R.color.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w700)),
                      ),
                      Container(height: 1, width: 72, color: R.color.grayComponentBorder)
                    ]),
                    SizedBox(width: 8),
                    Text('kcal')
                  ]),
                  Container(
                    margin: EdgeInsets.only(top: 32, bottom: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                width: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: R.color.grayBorder),
                                child: Center(
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              final calo = double.parse(
                                  textEditingController.text ?? '0');
                              if (calo <= 0) {
                                Message.showToastMessage(context,
                                    'Bạn chưa nhập thời gian vận động');
                                return;
                              }
                              widget.callback(textEditingController.text ?? '');
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 43,
                              width: 150,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ]),
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Center(
                                child: Text('Đồng ý',
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
