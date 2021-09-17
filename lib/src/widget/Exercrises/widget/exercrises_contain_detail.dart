import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_summary.dart';
import 'package:medical/src/modal/exercrises/exercrise_walk_summary.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:medical/src/modal/error/error_model.dart';

class ExercrisesDetail extends StatefulWidget {
  ExercrisesDetail({Key key}) : super(key: key);

  @override
  ExercrisesDetailState createState() => ExercrisesDetailState();
}

class ExercrisesDetailState extends State<ExercrisesDetail>
    with AutomaticKeepAliveClientMixin<ExercrisesDetail> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  reloadData(int periodFilter) {
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchDataDaily(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    ));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
            builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          ExercriseSummaryModel exercriseSummaryModel;
          ExercriseWalkSummaryModel exercriseWalkSummaryModel;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchDataDaily(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
            ));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is ExercrisesLoading) {
            return SizedBox();
          }
          if (state is ExercriseDataDailyLoaded) {
            exercriseSummaryModel = state.exercriseSummaryModel;
            exercriseWalkSummaryModel = state.exercriseWalkSummaryModel;
          }

          return exercriseSummaryModel == null &&
                  exercriseWalkSummaryModel == null
              ? Container(
                  height: 340,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hoạt động trong ngày',
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                  colors: [
                                    R.color.color0xffB1DDDB.withAlpha(90),
                                    R.color.color0xFFFED31B.withAlpha(40),
                                  ],
                                  begin: FractionalOffset(0.3, 0.0),
                                  end: FractionalOffset(0.0, 1),
                                  stops: [0.0, 1.0])),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          SizedBox(
                                              width: 130.0,
                                              height: 130.0,
                                              child: CustomPaint(
                                                  painter: GradientArcPainter(
                                                progress: 1,
                                                startColor: R.color.white,
                                                endColor: R.color.white,
                                                width: 8.0,
                                              ))),
                                          SizedBox(
                                              width: 130.0,
                                              height: 130.0,
                                              child: CustomPaint(
                                                  painter: GradientArcPainter(
                                                progress: exercriseSummaryModel
                                                        .factDuration /
                                                    exercriseSummaryModel
                                                        .targetDuration,
                                                startColor: R.color.green,
                                                endColor: R.color.green
                                                    .withOpacity(0.8),
                                                width: 8.0,
                                              ))),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${exercriseSummaryModel.factDuration.toInt().toString()}",
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 40.0),
                                              ),
                                              Text(
                                                "/${exercriseSummaryModel.targetDuration.toInt().toString()} phút",
                                                style: TextStyle(
                                                    color: R.color.primaryGreyColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.0),
                                              ),
                                            ],
                                          )
                                        ]),
                                    Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/clock_exe.png',
                                                width: 24,
                                                height: 24,
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                exercriseSummaryModel
                                                    .durationRatio
                                                    .toInt()
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 32.0),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  '%',
                                                  style: TextStyle(
                                                      color: R.color.primaryGreyColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/fire_exe.png',
                                                width: 24,
                                                height: 24,
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                exercriseSummaryModel
                                                    .burnedCalories
                                                    .toInt()
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 32.0),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  'kcal',
                                                  style: TextStyle(
                                                      color: R.color.primaryGreyColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child:
                                    Container(height: 1, color: R.color.white),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 32),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            exercriseSummaryModel
                                                        .mainExerciseIconUrl ==
                                                    null
                                                ? ''
                                                : exercriseSummaryModel
                                                        .mainExerciseIconUrl
                                                        .url ??
                                                    '',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  exercriseSummaryModel
                                                      .mainExerciseName,
                                                  style: TextStyle(
                                                      color: R.color.primaryGreyColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0)),
                                              SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(
                                                      exercriseSummaryModel
                                                                  .mainExerciseDuration ==
                                                              0
                                                          ? '--'
                                                          : exercriseSummaryModel
                                                              .mainExerciseDuration
                                                              .toInt()
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: R.color.textDark,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 20.0)),
                                                  SizedBox(width: 4),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2.0),
                                                    child: Text('phút',
                                                        style: TextStyle(
                                                            color:
                                                                R.color.primaryGreyColor,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: 1,
                                      height: 60,
                                      color: R.color.white),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 32),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            exercriseSummaryModel
                                                        .otherExerciseIconUrl ==
                                                    null
                                                ? ''
                                                : exercriseSummaryModel
                                                        .otherExerciseIconUrl
                                                        .url ??
                                                    '',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  exercriseSummaryModel
                                                      .otherExerciseName,
                                                  style: TextStyle(
                                                      color:  R.color.primaryGreyColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Text(
                                                        exercriseSummaryModel
                                                                    .otherExerciseDuration ==
                                                                0
                                                            ? '--'
                                                            : exercriseSummaryModel
                                                                .otherExerciseDuration
                                                                .toInt()
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: R.color.textDark,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 20.0)),
                                                    SizedBox(width: 4),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2.0),
                                                      child: Text('phút',
                                                          style: TextStyle(
                                                              color:
                                                                   R.color.primaryGreyColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14.0)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        exercriseWalkSummaryModel == null
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Đi bộ trong ngày',
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700)),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                barrierColor: R.color.color0xff003F38
                                                    .withOpacity(0.5),
                                                context: context,
                                                builder: (_) =>
                                                    CustomInputTimePicker(
                                                        title:
                                                            'Số phút đi bộ mỗi ngày',
                                                        time: 60,
                                                        callback:
                                                            (hour, minute) {
                                                          submitTarget(
                                                              hour * 60.0 +
                                                                  minute,
                                                              exercriseWalkSummaryModel
                                                                  .id);
                                                        }));
                                          },
                                          child: Container(
                                            color: R.color.transparent,
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/circle_plus_exe.png',
                                                  width: 24,
                                                  height: 24,
                                                ),
                                                SizedBox(width: 4),
                                                Text('Mục tiêu mới',
                                                    style: TextStyle(
                                                        color: R.color.mainColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 16),
                                        padding: EdgeInsets.only(left: 16),
                                        decoration: BoxDecoration(
                                          color: R.color.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Padding(
                                            //   padding: const EdgeInsets.only(top: 0.0),
                                            //   child: Text('Chi tiết',
                                            //       style: TextStyle(
                                            //           color: R.color.black,
                                            //           fontSize: 16,
                                            //           fontWeight: FontWeight.w700)),
                                            // ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/shoe_exe.png',
                                                              width: 24,
                                                              height: 24,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                                exercriseWalkSummaryModel
                                                                    .factDuration
                                                                    .toInt()
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Viga',
                                                                    color:
                                                                        R.color.textDark,
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4.0,
                                                                      left: 2),
                                                              child: Text(
                                                                "/ ${exercriseWalkSummaryModel.targetDuration.toInt().toString()} phút",
                                                                style: TextStyle(
                                                                    color:
                                                                         R.color.primaryGreyColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        14.0),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/fire_exe.png',
                                                              width: 24,
                                                              height: 24,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                                exercriseWalkSummaryModel
                                                                    .burnedCalories
                                                                    .toInt()
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Viga',
                                                                    color:
                                                                        R.color.textDark,
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 2.0,
                                                                      left: 2),
                                                              child: Text(
                                                                'kcal',
                                                                style: TextStyle(
                                                                    color:
                                                                         R.color.primaryGreyColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        16.0),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 16,
                                                        ),
                                                        Container(
                                                            height: 1,
                                                            width: 375,
                                                            color: R.color.color0xffD6D8E0),
                                                        SizedBox(
                                                          height: 16,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Image.network(
                                                              exercriseWalkSummaryModel
                                                                      .targetIconUrl
                                                                      .url ??
                                                                  '',
                                                              width: 24,
                                                              height: 34,
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  exercriseWalkSummaryModel
                                                                      .targetDescription,
                                                                  style: TextStyle(
                                                                      color:
                                                                          R.color.textDark,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14.0)),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Image.asset(
                                                  'assets/images/runner.png',
                                                  width: 109,
                                                  height: 178,
                                                )
                                              ],
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                      ]),
                ));
        }));
  }

  handlePercent(ExercriseSummaryModel exercriseSummaryModel) {
    final percent = exercriseSummaryModel.factDuration /
        exercriseSummaryModel.targetDuration;
    if (percent > 1) {
      return 1.0;
    }
    return percent;
  }

  submitTarget(double time, String exerciseCategoryId) async {
    try {
      BotToast.showLoading();
      await ExercrisesClient()
          .addExercriseTarget(1, 1, time, exerciseCategoryId);
      UserClient().fetchUser();
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
}
