import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/emotion/emotion_bloc.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_model.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Emotion/emotion_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class EmotionDistributionChart extends StatefulWidget {
  EmotionDistributionChart({Key key}) : super(key: key);
  @override
  EmotionDistributionChartState createState() =>
      EmotionDistributionChartState();
}

class EmotionDistributionChartState extends State<EmotionDistributionChart>
    with AutomaticKeepAliveClientMixin<EmotionDistributionChart> {
  @override
  bool get wantKeepAlive => true;
  int periodFilterType = 1;
  BuildContext currentContext;

  @override
  void initState() {
    periodFilterType =
        EmotionDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<EmotionBloc>(currentContext).add(FetchEmotionStatistic(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<EmotionBloc>(
        create: (context) => EmotionBloc(),
        child: BlocBuilder<EmotionBloc, EmotionState>(
            builder: (BuildContext context, EmotionState state) {
          currentContext = context;
          EmotionStatisticModel model;
          int count = 0;

          if (state is EmotionInitial) {
            BlocProvider.of<EmotionBloc>(context).add(FetchEmotionStatistic(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is EmotionError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is EmotionStatisticLoaded) {
            model = state.model;
            model.emotions.forEach((element) {
              count += element.count;
            });
          }
          return model == null
              ? Container(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/bg_emotion_1.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                    'Cảm xúc của bạn ${periodFilterType == 1 ? '7' : periodFilterType == 2 ? '14' : periodFilterType == 3 ? '30' : '90'} ngày qua',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ]),
                        count == 0
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/add_emo',
                                      arguments: {'type': 'input'});
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 16, left: 16, right: 16),
                                  child: Image.asset(
                                      'assets/images/icon_emotion_empty.png'),
                                ),
                              )
                            : Column(children: [
                                model.note == null || model.note.isEmpty
                                    ? SizedBox(height: 16)
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 12.0),
                                                    child: Image.network(
                                                      model.noteIcon.url ?? '',
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Expanded(
                                                    child: Text(model.note,
                                                        style: TextStyle(
                                                            color: R.color.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Image.network(
                                                model.noteImage.url ?? '',
                                                width: 130,
                                                height: 100,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: buildChart(model),
                                )
                              ])
                      ],
                    ),
                  ),
                );
        }));
  }

  // final width = MediaQuery.of(context).size.width;
  // final height = 37.0;

  buildChart(EmotionStatisticModel model) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: R.color.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ], borderRadius: BorderRadius.circular(14), color: R.color.white),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    centerSpaceRadius: (width / 7),
                    sections: List.generate(model.emotions.length, (i) {
                      final double radius = 20;
                      return PieChartSectionData(
                        color: toColor(model.emotions[i].colorCode),
                        value: model.emotions[i].count /
                            model.emotions.length *
                            100,
                        showTitle: false,
                        radius: radius,
                      );
                    })),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chú thích:',
                style: TextStyle(fontSize: 14, color: textDark),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        model.emotions.length,
                        (index) => GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/emotionTable',
                                    arguments: {
                                      'title': model.emotions[index].text,
                                      'emotionId': model.emotions[index].id,
                                      'periodFilterType': periodFilterType
                                    });
                              },
                              child: Container(
                                height: 40,
                                color: R.color.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      model.emotions[index].icon.url ?? '',
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(model.emotions[index].text,
                                        style: TextStyle(
                                            fontSize: 14, color: textDark))
                                  ],
                                ),
                              ),
                            )),
                  ),
                  SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        model.emotions.length,
                        (index) => GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/emotionTable',
                                    arguments: {
                                      'title': model.emotions[index].text,
                                      'emotionId': model.emotions[index].id,
                                      'periodFilterType': periodFilterType
                                    });
                              },
                              child: Container(
                                  height: 40,
                                  color: R.color.transparent,
                                  child: Center(
                                    child: Text(
                                        model.emotions[index].count.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Viga',
                                            fontSize: 20,
                                            color: toColor(model
                                                .emotions[index].colorCode),
                                            fontWeight: FontWeight.w500)),
                                  )),
                            )),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
