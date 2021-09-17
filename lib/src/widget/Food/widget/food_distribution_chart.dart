import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/components/samples/pie_chart/samples/indicator.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class FoodDistributionChart extends StatefulWidget {
  FoodDistributionChart({Key key}) : super(key: key);
  @override
  FoodDistributionChartState createState() => FoodDistributionChartState();
}

class FoodDistributionChartState extends State<FoodDistributionChart>
    with AutomaticKeepAliveClientMixin<FoodDistributionChart> {
  @override
  bool get wantKeepAlive => true;
  BuildContext currentContext;
  int periodFilterType = 1;
  bool isEnergyTab = true;
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
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticDistribute(
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
          FoodDistributeModel model;
          double total = 0;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticDistribute(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticDistributeLoaded) {
            model = state.model;
            final data = isEnergyTab ? model.energyChart : model.carbChart;
            data.forEach((element) {
              total += element.percentValue;
            });
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Padding(
                  padding:
                      EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Năng lượng phân bổ',
                          style: TextStyle(
                              color: R.color.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 16),
                      total == 0
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/add_food',
                                    arguments: {'type': 'input', 'id': null});
                              },
                              child: Image.asset(
                                'assets/images/food_empty.png',
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(14),
                                  color: R.color.white),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 32,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isEnergyTab = true;
                                            });
                                          },
                                          child: Container(
                                              height: 32,
                                              width: 135,
                                              padding: EdgeInsets.only(
                                                  left: 18, right: 18),
                                              decoration: BoxDecoration(
                                                  color: isEnergyTab
                                                      ? Color(0xff01645A)
                                                      : R.color.transparent,
                                                  border: Border.all(
                                                      color: isEnergyTab
                                                          ? Color(0xff01645A)
                                                          : Color(0xff666666),
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              child: Center(
                                                child: Text('Năng lượng',
                                                    style: TextStyle(
                                                        color: isEnergyTab
                                                            ? R.color.white
                                                            : Color(0xff666666),
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
                                                  color: isEnergyTab
                                                      ? R.color.transparent
                                                      : Color(0xff01645A),
                                                  border: Border.all(
                                                      color: isEnergyTab
                                                          ? Color(0xff666666)
                                                          : R.color.white,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              child: Center(
                                                child: Text('Chất bột đường',
                                                    style: TextStyle(
                                                        color: isEnergyTab
                                                            ? Color(0xff666666)
                                                            : R.color.white,
                                                        fontSize: 14,
                                                        fontWeight: isEnergyTab
                                                            ? FontWeight.w400
                                                            : FontWeight.w700)),
                                              )),
                                        )
                                      ]),
                                  Row(
                                    children: <Widget>[
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
                                                centerSpaceRadius: 60,
                                                sections: List.generate(
                                                    isEnergyTab
                                                        ? model
                                                            .energyChart.length
                                                        : model.carbChart
                                                            .length, (i) {
                                                  final double radius = 35;
                                                  final item = isEnergyTab
                                                      ? model.energyChart[i]
                                                      : model.carbChart[i];
                                                  return PieChartSectionData(
                                                    color:
                                                        toColor(item.colorCode),
                                                    value: item.percentValue,
                                                    showTitle: false,
                                                    radius: radius,
                                                  );
                                                })),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2.0, bottom: 8),
                                            child: Text(
                                              'Chú thích',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: textDark),
                                            ),
                                          ),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                  isEnergyTab
                                                      ? model.energyChart.length
                                                      : model.carbChart.length,
                                                  (i) {
                                                final item = isEnergyTab
                                                    ? model.energyChart[i]
                                                    : model.carbChart[i];
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 4),
                                                  child: Indicator(
                                                    color:
                                                        toColor(item.colorCode),
                                                    number: roundNumber(
                                                            item.percentValue) +
                                                        '%',
                                                    text: item.text,
                                                    textColor: R.color.white,
                                                    isSquare: true,
                                                  ),
                                                );
                                              })),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 28,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                );
        }));
  }
}
