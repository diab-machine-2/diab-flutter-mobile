import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StarchChart extends StatefulWidget {
  StarchChart({Key key}) : super(key: key);
  @override
  StarchChartState createState() => StarchChartState();
}

class StarchChartState extends State<StarchChart>
    with AutomaticKeepAliveClientMixin<StarchChart> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;
  int periodFilterType = 1;

  int touchIndex;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticCarb());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = (MediaQuery.of(context).size.width - 32);
    final height = width / 1029 * 1044;
    final heightApple = 185 * height / 348;

    final heightLA = height * 22 / 348;
    final top = height * 56 / 348;
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodCaloModel model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticCarb());
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticCarbLoaded) {
            model = state.model;
          }

          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(children: [
                      Positioned(
                        top: 57,
                        left: 0,
                        child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              SizedBox(
                                  width: heightApple,
                                  height: heightApple,
                                  child: CustomPaint(
                                      painter: GradientArcPainter(
                                    progress: 1,
                                    startColor: R.color.white,
                                    endColor: R.color.white,
                                    width: 56,
                                  ))),
                              SizedBox(
                                  width: heightApple,
                                  height: heightApple,
                                  child: CustomPaint(
                                      painter: GradientArcPainter(
                                    progress:
                                        model.goal == null || model.goal == 0
                                            ? 0
                                            : model.total / model.goal,
                                    startColor: toColor(model.colorCode)
                                        .withOpacity(0.3),
                                    endColor: toColor(model.colorCode),
                                    width: 56,
                                  ))),
                            ]),
                      ),
                      Positioned(
                        top: top,
                        left: 0,
                        child: Center(
                          child: Container(
                              height: heightLA,
                              width: heightApple,
                              color: toColor(model.colorCode)),
                        ),
                      ),
                      Image.asset('assets/images/apple_green.png'),
                      Padding(
                        padding: EdgeInsets.only(top: 16, left: 16),
                        child: Text('Tinh bột',
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ),
                      Positioned(
                          top: top,
                          left: 0,
                          child: Container(
                            width: heightApple,
                            height: heightApple,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/icon_bat.png',
                                        width: 24, height: 24),
                                    SizedBox(width: 4),
                                    Text(model.total.round().toString(),
                                        style: TextStyle(
                                            fontFamily: 'Viga',
                                            color: R.color.black,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w400)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                    model.goal == null
                                        ? '0 g'
                                        : '/${formatNumber(model.goal)} g',
                                    style: TextStyle(color: R.color.primaryGreyColor))
                              ],
                            ),
                          )),
                      Positioned(
                        top: 38,
                        right: 43,
                        child: SizedBox(
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                    model.mealDetails.length,
                                    (index) => Row(children: [
                                          Image.network(
                                              model.mealDetails[index].icon
                                                      .url ??
                                                  '',
                                              width: 24,
                                              height: 24),
                                          SizedBox(width: 4),
                                          Text(model.mealDetails[index].text),
                                        ])),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                    model.mealDetails.length,
                                    (index) => SizedBox(
                                          height: 24,
                                          child: Text(
                                              model.mealDetails[index].value
                                                  .round()
                                                  .toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Viga',
                                                  color: R.color.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 18)),
                                        )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Image.network(model.image.url ?? '',
                                width: 77, height: 102),
                            SizedBox(width: 25),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  model.percent == null || model.percent == 0
                                      ? SizedBox()
                                      : Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(roundNumber(model.percent),
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text('%')
                                              ],
                                            ),
                                            LinearPercentIndicator(
                                              width: 140.0,
                                              lineHeight: 10.0,
                                              percent: model.percent > 100
                                                  ? 1
                                                  : (model.percent / 100),
                                              backgroundColor: R.color.green
                                                  .withOpacity(0.2),
                                              progressColor: R.color.green,
                                            ),
                                          ],
                                        ),
                                  SizedBox(height: 12),
                                  Text(model.note),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                );
        }));
  }
}
