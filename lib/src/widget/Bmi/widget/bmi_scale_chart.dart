import 'dart:ui';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/weight/weight_bloc.dart';
import 'package:medical/src/modal/bmi/bmi_trend.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Bmi/bmi_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BmiScaleChart extends StatefulWidget {
  BmiScaleChart({Key key}) : super(key: key);

  @override
  BmiScaleChartState createState() => BmiScaleChartState();
}

class BmiScaleChartState extends State<BmiScaleChart>
    with AutomaticKeepAliveClientMixin<BmiScaleChart> {
  @override
  bool get wantKeepAlive => true;
  BuildContext currentContext;
  int periodFilterType = 1;
  int trendTypeIndex = 1;
  int touchIndex = -1;
  String trendType = 'Tất cả';

  @override
  void initState() {
    periodFilterType = BmiDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'active_change_data', observer: this);
    super.dispose();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<WeightBloc>(currentContext).add(FetchTrendBMI(
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
    return BlocProvider<WeightBloc>(
        create: (context) => WeightBloc(),
        child: BlocBuilder<WeightBloc, WeightState>(
            builder: (BuildContext context, WeightState state) {
          currentContext = context;
          TrendBmiModel model;

          if (state is WeightInitial) {
            print(periodFilterType);
            BlocProvider.of<WeightBloc>(context).add(FetchTrendBMI(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is WeightError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is WeightTrendBMILoaded) {
            model = state.trendBMI;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BMI',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                model.value == null || model.value == 0
                                    ? '--'
                                    : roundNumber(model.value),
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: model.value == null ||
                                            model.value == 0
                                        ? Colors.black
                                        : toColor(
                                            model.currentLedend.colorCode))),
                            model.currentLedend == null
                                ? SizedBox()
                                : Container(
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, top: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                        color: toColor(model
                                            .currentLedend.backgroundColorCode),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(13),
                                            topRight: Radius.circular(13),
                                            bottomLeft: Radius.circular(13))),
                                    child: Text('${model.currentLedend.text}',
                                        style: TextStyle(
                                            color: toColor(model
                                                .currentLedend.textcolorCode),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700)),
                                  ),
                          ],
                        ),

                        SizedBox(height: 20),
                        Container(
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Padding(
                                //   padding: EdgeInsets.only(top: 18, bottom: 16),
                                //   child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceAround,
                                //       children: []),
                                // ),
                                // model.trendItems.items.length != 0
                                //     ? GestureDetector(
                                //         onTap: () {
                                //           Navigator.pushNamed(
                                //               context, '/add_bmi',
                                //               arguments: {
                                //                 'type': 'input',
                                //               });
                                //         },
                                //         child: Image.asset(
                                //             'assets/images/nothing_chart_weight.png'),
                                //       )
                                //     :
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color:
                                    //         Colors.grey.withOpacity(0.5),
                                    //     spreadRadius: 1,
                                    //     blurRadius: 7,
                                    //     offset: Offset(0,
                                    //         2), // changes position of shadow
                                    //   ),
                                    // ],
                                  ),
                                  padding: EdgeInsets.only(
                                      top: 32, left: 16, right: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      model.value == null || model.value == 0
                                          ? Image.asset(
                                              'assets/images/bmi_empty.png')
                                          : buildChart(model),
                                      SizedBox(height: 16),
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Chú thích:'),
                                      ),
                                      model.legends.length == 0
                                          ? SizedBox()
                                          : buildDescription(
                                              model.legends.sublist(0, 3)),
                                      model.legends.length == 0
                                          ? SizedBox()
                                          : buildDescription(
                                              model.legends.sublist(3, 5))
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 16),
                        // buildDescription(model)
                      ]),
                );
        }));
  }

  Widget buildDescription(List<LegendsModel> legends) {
    List<Widget> items = [];
    legends.forEach((element) {
      items.add(buildDescriptionItem(element));
    });
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: items),
    );
  }

  Widget buildDescriptionItem(LegendsModel model) {
    print(model);
    final String color = model.colorCode;
    final String title = model.text;
    return Row(children: [
      Container(
          width: 14,
          height: 14,
          color: Color(int.parse('0xff${color.split('#').join()}'))),
      SizedBox(width: 4),
      Text(title)
    ]);
  }

  Widget buildChart(TrendBmiModel model) {
    final bmi = model.value;
    List<double> numbers = [0, 18.5, 23, 25, 30, 40];
    List<double> percents = [0, 20, 40, 60, 80, 100];
    int index = 0;
    if (bmi >= 0 && bmi <= 18.5) {
      index = 0;
    } else if (bmi > 18.5 && bmi <= 23) {
      index = 1;
    } else if (bmi > 23 && bmi <= 25) {
      index = 2;
    } else if (bmi > 25 && bmi <= 30) {
      index = 3;
    } else if (bmi > 30) {
      index = 4;
    }
    final percent =
        (bmi - numbers[index]) / (numbers[index + 1] - numbers[index]) * 100;

    final bmiNumber = ((percents[index] + (percent * 0.2))) * (40 / 100);
    return Container(
        height: 170,
        child: Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: [
              Positioned(
                top: -180,
                left: 8,
                right: 8,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                        showAxisLine: false,
                        showLabels: false,
                        showTicks: false,
                        startAngle: 180,
                        endAngle: 360,
                        minimum: 0,
                        maximum: 40,
                        centerY: 1,
                        radiusFactor: 1,
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            needleStartWidth: 0,
                            needleEndWidth: 0,
                            knobStyle: KnobStyle(
                                knobRadius: 0.07, color: Color(0xffEFEFEF)),
                          ),
                          NeedlePointer(
                            needleStartWidth: 0.1,
                            lengthUnit: GaugeSizeUnit.factor,
                            needleEndWidth: 5,
                            needleLength: 0.65,
                            needleColor: mainColor,
                            value: bmiNumber,
                            knobStyle: KnobStyle(knobRadius: 0),
                          ),
                          NeedlePointer(
                            needleStartWidth: 0,
                            needleEndWidth: 0,
                            knobStyle:
                                KnobStyle(knobRadius: 0.0275, color: mainColor),
                          ),
                          NeedlePointer(
                            needleStartWidth: 0,
                            needleEndWidth: 0,
                            knobStyle: KnobStyle(
                                knobRadius: 0.005, color: Colors.white),
                          )
                        ],
                        ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: 0,
                              endValue: 7.8,
                              startWidth: 0.2,
                              endWidth: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              color: const Color(0xffF58220)),
                          GaugeRange(
                              startValue: 8.2,
                              endValue: 15.8,
                              startWidth: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              endWidth: 0.2,
                              color: const Color(0xff50C087)),
                          GaugeRange(
                              startValue: 16.2,
                              endValue: 23.8,
                              startWidth: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              endWidth: 0.2,
                              color: const Color(0xffFFE3E3)),
                          GaugeRange(
                              startValue: 24.2,
                              endValue: 31.8,
                              startWidth: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              endWidth: 0.2,
                              color: const Color(0xffFF8E8E)),
                          GaugeRange(
                              startValue: 32.2,
                              endValue: 39.8,
                              sizeUnit: GaugeSizeUnit.factor,
                              startWidth: 0.2,
                              endWidth: 0.2,
                              color: const Color(0xffE53935)),
                        ]),
                    RadialAxis(
                      minorTicksPerInterval: 8,
                      tickOffset: 0,
                      minorTickStyle:
                          MinorTickStyle(color: Color(0xffDDDDDD), length: 2),
                      majorTickStyle:
                          MajorTickStyle(color: Color(0xffDDDDDD), length: 2),
                      showAxisLine: false,
                      showLabels: false,
                      showTicks: true,
                      startAngle: 180,
                      endAngle: 360,
                      minimum: 0,
                      maximum: 40,
                      radiusFactor: 0.75,
                      centerY: 1,
                      pointers: <GaugePointer>[
                        MarkerPointer(
                            markerType: MarkerType.text,
                            value: 0,
                            textStyle: GaugeTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xff666666)),
                            offsetUnit: GaugeSizeUnit.factor,
                            markerOffset: -0.5),
                        MarkerPointer(
                            markerType: MarkerType.text,
                            text: '18.5',
                            value: 8,
                            textStyle: GaugeTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xff666666)),
                            offsetUnit: GaugeSizeUnit.factor,
                            markerOffset: -0.5),
                        MarkerPointer(
                            markerType: MarkerType.text,
                            text: '23',
                            value: 16,
                            textStyle: GaugeTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xff666666)),
                            offsetUnit: GaugeSizeUnit.factor,
                            markerOffset: -0.5),
                        MarkerPointer(
                            markerType: MarkerType.text,
                            text: '25',
                            value: 24,
                            textStyle: GaugeTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xff666666)),
                            offsetUnit: GaugeSizeUnit.factor,
                            markerOffset: -0.5),
                        MarkerPointer(
                            markerType: MarkerType.text,
                            text: '30',
                            value: 32,
                            textStyle: GaugeTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xff666666)),
                            offsetUnit: GaugeSizeUnit.factor,
                            markerOffset: -0.5)
                      ],
                    ),
                  ],
                ),
              )
            ]));
  }
}
