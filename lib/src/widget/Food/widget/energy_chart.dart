import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'dart:math' as math;

import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/Food/widget/add_target_food.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class EnergyChart extends StatefulWidget {
  EnergyChart({Key key}) : super(key: key);
  @override
  EnergyChartState createState() => EnergyChartState();
}

class EnergyChartState extends State<EnergyChart>
    with AutomaticKeepAliveClientMixin<EnergyChart> {
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
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticCalo());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = (MediaQuery.of(context).size.width - 32);
    final height = width / 1029 * 1044;
    final heightApple = 185 * height / 348;

    final heightLA = height * 22 / 348;
    final top = height * 66 / 348;

    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodCaloModel model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticCalo());
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticCaloLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(children: [
                      Positioned(
                        top: 70,
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
                                    width: 56.0,
                                  ))),
                              SizedBox(
                                  width: heightApple,
                                  height: heightApple,
                                  child: CustomPaint(
                                      painter: GradientArcPainter(
                                    progress: model.goal == null
                                        ? 0
                                        : model.total / model.goal,
                                    startColor: toColor(model.colorCode)
                                        .withOpacity(0.3),
                                    endColor: toColor(model.colorCode),
                                    width: 56.0,
                                  ))),
                            ]),
                      ),
                      Positioned(
                        top: top,
                        left: 0,
                        //right: 0,
                        child: Center(
                          child: Container(
                              height: heightLA,
                              width: heightApple,
                              color: toColor(model.colorCode)),
                        ),
                      ),
                      Image.asset(R.drawable.bg_apple_orange),
                      Padding(
                        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Năng lượng',
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  barrierColor:
                                      R.color.color0xff003F38.withOpacity(0.5),
                                  context: context,
                                  builder: (_) => AddTargetFood(
                                      goal: model.goal.round(),
                                      callback: (number) {
                                        updateGoal(number);
                                      }),
                                );
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
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 58,
                        right: 43,
                        child: SizedBox(
                          height: 200,
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  Image.asset(R.drawable.icon_bat,
                                      width: 24, height: 24),
                                  SizedBox(width: 4),
                                  Text(formatNumber(model.total),
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
                                      ? '0 kcal'
                                      : '/${formatNumber(model.goal)} kcal',
                                  style: TextStyle(color: R.color.primaryGreyColor))
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
                                width: 65, height: 110),
                            SizedBox(width: 25),
                            Expanded(
                              child: Text(model.note),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                );
        }));
  }

  updateGoal(int goal) async {
    BotToast.showLoading();
    try {
      await FoodClient().updateTargetEnergy(goal);
      UserClient().fetchUser();
      _refresh();
      DartNotificationCenter.post(channel: 'goal_calo_changed');
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

class GradientArcPainter extends CustomPainter {
  const GradientArcPainter({
    @required this.progress,
    @required this.startColor,
    @required this.endColor,
    @required this.width,
  })  : assert(progress != null),
        assert(startColor != null),
        assert(endColor != null),
        assert(width != null),
        super();

  final double progress;
  final Color startColor;
  final Color endColor;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient = new SweepGradient(
      startAngle: 3.2 * math.pi / 2,
      endAngle: 6.8 * math.pi / 2,
      tileMode: TileMode.repeated,
      colors: [startColor, startColor, endColor, endColor, startColor],
    );

    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.butt // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (width / 2);
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
