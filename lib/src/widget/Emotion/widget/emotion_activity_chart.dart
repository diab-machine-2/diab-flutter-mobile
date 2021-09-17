import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/emotion/emotion_bloc.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_item_model.dart';
import 'package:medical/src/widget/Emotion/emotion_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class EmotionActivityChart extends StatefulWidget {
  EmotionActivityChart({Key key}) : super(key: key);
  @override
  EmotionActivityChartState createState() => EmotionActivityChartState();
}

class EmotionActivityChartState extends State<EmotionActivityChart>
    with AutomaticKeepAliveClientMixin<EmotionActivityChart> {
  @override
  bool get wantKeepAlive => true;
  BuildContext currentContext;

  int periodFilterType = 1;

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
    BlocProvider.of<EmotionBloc>(currentContext).add(FetchActivityStatistic(
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
          List<EmotionStatisticItemModel> model;

          if (state is EmotionInitial) {
            BlocProvider.of<EmotionBloc>(context).add(FetchActivityStatistic(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is EmotionError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is ActivityStatisticLoaded) {
            model = state.activities;
          }
          return model == null
              ? SizedBox()
              : model.length == 0
                  ? SizedBox()
                  : Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                R.color.color0xFFC3E8D3.withOpacity(0.1),
                                R.color.color0xffB1DDDB.withOpacity(0.1),
                              ],
                              begin: FractionalOffset(0.1, 0.0),
                              end: FractionalOffset(0.5, 0.5),
                              stops: [0.0, 1.0])),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, bottom: 24, top: 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tổng quan hoạt động',
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 16),
                                child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    // padding: EdgeInsets.only(
                                    //     left: 10, right: 10, bottom: 8, top: 10),
                                    itemCount: model.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final name = model[index].text;
                                      final icon = model[index].icon.url;
                                      final quantity = model[index].count;
                                      final color = model[index].colorCode;

                                      return _buildItemSumary(context, index,
                                          name, icon, quantity, color);
                                    }),
                              ),
                            ]),
                      ),
                    );
        }));
  }

  Widget _buildItemSumary(BuildContext context, int index, String name,
      String icon, int quantity, String color) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network('$icon', width: 24, height: 24),
              SizedBox(
                width: 8,
              ),
              Text(name,
                  style: TextStyle(
                      color: R.color.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ],
          ),
          Text(quantity.toString(),
              style: TextStyle(
                  fontFamily: 'Viga',
                  color: toColor(color),
                  fontSize: 20,
                  fontWeight: FontWeight.w400))
        ],
      ),
    ));
  }
}
