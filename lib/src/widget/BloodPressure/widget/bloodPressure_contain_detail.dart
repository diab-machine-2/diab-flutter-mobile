import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_heart_rate.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class BloodPressureDetail extends StatefulWidget {
  BloodPressureDetail({Key key}) : super(key: key);

  @override
  BloodPressureDetailState createState() => BloodPressureDetailState();
}

class BloodPressureDetailState extends State<BloodPressureDetail>
    with AutomaticKeepAliveClientMixin<BloodPressureDetail> {
  @override
  bool get wantKeepAlive => true;
  int periodFilterType = 1;
  BuildContext currentContext;

  @override
  void initState() {
    periodFilterType =
        BloodPressureDetailTabbarController.of(context).periodFilterType;
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
    BlocProvider.of<BloodPressureBloc>(currentContext)
        .add(FetchHeartRateBloodPressure(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<BloodPressureBloc>(
        create: (context) => BloodPressureBloc(),
        child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
            builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          BloodPressureHeartRateModel model;
          BloodPressureModel modelLastest;

          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context)
                .add(FetchHeartRateBloodPressure(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: "1",
            ));
          }

          if (state is BloodPressureDataHeartRateLoaded) {
            model = state.bloodPressureHeartRateModel;
            modelLastest = state.lastestSummaryModel;
          }

          return Container(
            child: Column(
              children: [
                Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 20, bottom: 12),
                    child: Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Huyết áp',
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  BloodPressureDetailTabbarController.of(
                                          context)
                                      .loadInputWithId(
                                          1, model.diastolicLowestId);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 16, bottom: 16, left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              model == null
                                                  ? '--'
                                                  : model.systolicLowest
                                                                  .toInt() ==
                                                              0 &&
                                                          model.diastolicLowest
                                                                  .toInt() ==
                                                              0
                                                      ? '--'
                                                      : '${model.systolicLowest.toInt()}/${model.diastolicLowest.toInt()}'
                                                          .toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Viga',
                                                  color: model == null
                                                      ? R.color.black
                                                      : toColor(
                                                          model.lowestColor),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400)),
                                          SizedBox(width: 10),
                                          Image.asset(
                                              'assets/images/line_low.png',
                                              width: 20,
                                              height: 15)
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('Thấp nhất',
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 15,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 16, bottom: 16, left: 8, right: 8),
                                decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            model == null
                                                ? '--'
                                                : model.systolicAverage
                                                                .toInt() ==
                                                            0 &&
                                                        model.diastolicAverage
                                                                .toInt() ==
                                                            0
                                                    ? '--'
                                                    : '${model.systolicAverage.toInt()}/${model.diastolicAverage.toInt()}'
                                                        .toString(),
                                            style: TextStyle(
                                                fontFamily: 'Viga',
                                                color: model == null
                                                    ? R.color.black
                                                    : toColor(
                                                        model.averageColor),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400)),
                                        SizedBox(width: 10),
                                        Image.asset(
                                            'assets/images/line_average.png',
                                            width: 20,
                                            height: 15)
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text('Trung bình',
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 15,
                                          // fontWeight: FontWeight.w700
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  BloodPressureDetailTabbarController.of(
                                          context)
                                      .loadInputWithId(
                                          1, model.diastolicHighestId);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 16, bottom: 16, left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              model == null
                                                  ? '--'
                                                  : model.systolicHighest
                                                                  .toInt() ==
                                                              0 &&
                                                          model.diastolicHighest
                                                                  .toInt() ==
                                                              0
                                                      ? '--'
                                                      : '${model.systolicHighest.toInt()}/${model.diastolicHighest.toInt()}'
                                                          .toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Viga',
                                                  color: model == null
                                                      ? R.color.black
                                                      : toColor(
                                                          model.highestColor),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400)),
                                          SizedBox(width: 10),
                                          Image.asset(
                                              'assets/images/line_high.png',
                                              width: 20,
                                              height: 15)
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('Cao nhất',
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 15,
                                            // fontWeight: FontWeight.w700
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Nhịp tim',
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  BloodPressureDetailTabbarController.of(
                                          context)
                                      .loadInputWithId(
                                          1, model.pulseRateLowestId);
                                },
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: 16, bottom: 16, left: 8, right: 8),
                                    decoration: BoxDecoration(
                                      color: R.color.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                model == null
                                                    ? '--'
                                                    : model.pulseRateLowest == 0
                                                        ? "--"
                                                        : model.pulseRateLowest
                                                            .toInt()
                                                            .toString(),
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    color: model == null
                                                        ? R.color.black
                                                        : toColor(
                                                            model.lowestColor),
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            SizedBox(width: 10),
                                            Image.asset(
                                                'assets/images/line_low.png',
                                                width: 20,
                                                height: 15)
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text('Thấp nhất',
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 15,
                                            )),
                                      ],
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      top: 16, bottom: 16, left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              model == null
                                                  ? '--'
                                                  : model.pulseRateAverage == 0
                                                      ? '--'
                                                      : model.pulseRateAverage
                                                          .toInt()
                                                          .toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Viga',
                                                  color: model == null
                                                      ? R.color.black
                                                      : toColor(
                                                          model.averageColor),
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w400)),
                                          SizedBox(width: 10),
                                          Image.asset(
                                              'assets/images/line_average.png',
                                              width: 20,
                                              height: 15)
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('Trung bình',
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 15,
                                            // fontWeight: FontWeight.w700
                                          )),
                                    ],
                                  )),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  BloodPressureDetailTabbarController.of(
                                          context)
                                      .loadInputWithId(
                                          1, model.pulseRateHighestId);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 16, bottom: 16, left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              model == null
                                                  ? '--'
                                                  : model.pulseRateHighest == 0
                                                      ? '--'
                                                      : model.pulseRateHighest
                                                          .toInt()
                                                          .toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Viga',
                                                  color: model == null
                                                      ? R.color.black
                                                      : toColor(
                                                          model.highestColor),
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w400)),
                                          SizedBox(width: 10),
                                          Image.asset(
                                              'assets/images/line_high.png',
                                              width: 20,
                                              height: 15)
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('Cao nhất',
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 15,
                                            // fontWeight: FontWeight.w700
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gần nhất',
                                  style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Text('Nhập vào ',
                                      style: TextStyle(
                                        color: R.color.grayCaption,
                                        fontSize: 12,
                                      )),
                                  Text(
                                      modelLastest == null
                                          ? '--'
                                          : convertToUTC(
                                              modelLastest.date, 'dd/MM/yyyy'),
                                      style: TextStyle(
                                        color: R.color.grayCaption,
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          modelLastest == null
                              ? SizedBox()
                              : Container(
                                  decoration: BoxDecoration(
                                      color:
                                          toColor(modelLastest.backgroundColor),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(13),
                                          topRight: Radius.circular(13),
                                          bottomLeft: Radius.circular(13))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 8, bottom: 8),
                                    child: Text(
                                        modelLastest == null
                                            ? '--'
                                            : modelLastest.bloodPressureType,
                                        style: TextStyle(
                                            color:
                                                toColor(modelLastest.fontColor),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ))
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Huyết áp',
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 18,
                                  )),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                      modelLastest == null
                                          ? '--/--'
                                          : modelLastest.systolic.toInt() ==
                                                      0 &&
                                                  modelLastest.diastolic
                                                          .toInt() ==
                                                      0
                                              ? '--'
                                              : '${modelLastest.systolic.toInt()}/${modelLastest.diastolic.toInt()}'
                                                  .toString(),
                                      style: TextStyle(
                                          fontFamily: 'Viga',
                                          color: modelLastest == null
                                              ? R.color.black
                                              : toColor(modelLastest.color),
                                          fontSize: 32,
                                          fontWeight: FontWeight.w400)),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text('mmHg',
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 18,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nhịp tim',
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16,
                                  )),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                      modelLastest == null
                                          ? '--'
                                          : modelLastest.pulseRate.toInt() == 0
                                              ? '--'
                                              : modelLastest.pulseRate
                                                  .toInt()
                                                  .toString(),
                                      style: TextStyle(
                                          fontFamily: 'Viga',
                                          color: R.color.textDark,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w400)),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 14.0),
                                    child: Text('lần/phút',
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 14),
                    ]),
                  ),
                ]),
              ],
            ),
          );
        }));
  }
}
