import 'dart:ui';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/src/modal/exercrises/excercise_rank_model.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class ExercrisesRankingChart extends StatefulWidget {
  ExercrisesRankingChart({Key key}) : super(key: key);
  @override
  ExercrisesRankingChartState createState() => ExercrisesRankingChartState();
}

class ExercrisesRankingChartState extends State<ExercrisesRankingChart>
    with AutomaticKeepAliveClientMixin<ExercrisesRankingChart> {
  @override
  bool get wantKeepAlive => true;
  BuildContext currentContext;
  int type = 1;

  int periodFilterType = 1;

  final List<List<Color>> colors = [
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xff96d7b4, R.color.color0xffadd89e],
    [R.color.color0xffC1D98B.withOpacity(0.5), R.color.color0xffaad8a2],
    [R.color.color0xffC1D98B.withOpacity(0.8), R.color.color0xffC1D98B],
    [R.color.color0xffDADA72.withOpacity(0.8), R.color.color0xffDADA72],
    [R.color.color0xffDADA72.withOpacity(0.8), R.color.color0xffDADA72],
    [R.color.color0xffDADA72.withOpacity(0.8), R.color.color0xffDADA72],
    [R.color.color0xffDADA72.withOpacity(0.8), R.color.color0xffDADA72],
    [R.color.color0xffE2DB6B.withOpacity(0.8), R.color.color0xffE2DB6B],
    [R.color.color0xffE2DB6B.withOpacity(0.8), R.color.color0xffE2DB6B],
    [R.color.color0xffE2DB6B.withOpacity(0.8), R.color.color0xffE2DB6B],
    [R.color.color0xffE2DB6B.withOpacity(0.8), R.color.color0xffE2DB6B],
    [R.color.color0xffE2DB6B.withOpacity(0.8), R.color.color0xffE2DB6B],
    [R.color.color0xE2DB6B, R.color.color0xE2DB6B]
  ];

  @override
  void initState() {
    periodFilterType =
        ExercrisesDetailTabbarController.of(context).periodFilterType;
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
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchRank(
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
          ExerciseRankModel model;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchRank(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is RankLoaded) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Xếp hạng thời gian vận động',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        SizedBox(height: 20),
                        1 == 2
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, NavigatorName.add_exercrises,
                                      arguments: {
                                        'type': 'input',
                                      });
                                },
                                child: Image.asset(
                                  R.drawable.nothing,
                                ),
                              )
                            : Container(
                                width: width,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          R.color.greenbg,
                                          R.color.color0xFFFFF7C0,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: [0.0, 1.0]),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0,
                                          bottom: 16,
                                          left: 16,
                                          right: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            R.drawable.badge_exe,
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: List.generate(
                                                  colors.length, (index) {
                                                return buildItem(
                                                    model,
                                                    130 - (index * 6.3),
                                                    colors[index].first,
                                                    colors[index].last,
                                                    index);
                                              }),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2, top: 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('5%'),
                                                // Container(
                                                //     width: 8,
                                                //     height: 8,
                                                //     decoration: BoxDecoration(
                                                //       color: green,
                                                //       borderRadius:
                                                //           BorderRadius.circular(
                                                //               4),
                                                //     )),
                                                Text('100%'),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: R.color.color0xff72CB9C,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  )),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                  'Bình quân trong nhóm tuổi của tôi: ',
                                                  style: TextStyle(
                                                      color: R.color.textDark,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0)),
                                              Text(
                                                  model.averagePercent
                                                          .round()
                                                          .toString() +
                                                      '%',
                                                  style: TextStyle(
                                                      color: R.color.color0xff72CB9C,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14.0)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                        height: 0.5, color: R.color.mainColor),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 16,
                                          left: 32,
                                          right: 32,
                                          bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(model.description,
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.0)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                        SizedBox(height: 16),
                        // buildDescription(model)
                      ]),
                );
        }));
  }

  double getIndex(double averagePercent) {
    final number = ((averagePercent / 10).round() * 10) - averagePercent;
    final average = number < 5
        ? ((averagePercent / 10).round() * 10)
        : ((averagePercent / 10).round() * 10) - 5;
    final avarageIndex = average / 5;
    return avarageIndex;
  }

  Widget buildItem(ExerciseRankModel model, double height, Color startColor,
      Color endColor, int index) {
    final avarageIndex = getIndex(model.averagePercent);

    final partientIndex = getIndex(model.partientPercent);
    return Column(
      children: [
        Container(
          width: 8,
          height: height,
          decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                  begin: Alignment(0, 0.5),
                  end: Alignment(0, 0.5),
                  colors: partientIndex == index
                      ? [R.color.mainColor, R.color.mainColor]
                      : index == avarageIndex
                          ? [R.color.color0xff72CB9C, R.color.color0xff72CB9C]
                          : [
                              startColor,
                              endColor.withOpacity(0.8),
                            ])),
        ),
        SizedBox(height: 8),
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: partientIndex == index
                  ? R.color.mainColor
                  : index == avarageIndex
                      ? R.color.color0xff72CB9C
                      : R.color.transparent,
              borderRadius: BorderRadius.circular(4),
            )),
      ],
    );
  }
}
