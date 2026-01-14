import 'dart:math' as math;

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class EnergyChart extends StatefulWidget {
  const EnergyChart({Key? key}) : super(key: key);
  @override
  EnergyChartState createState() => EnergyChartState();
}

class EnergyChartState extends State<EnergyChart>
    with AutomaticKeepAliveClientMixin<EnergyChart> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;

  int? touchIndex;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
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

    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodCaloModel? model;
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
                  height: 100,
                  child: const Center(child: CircularProgressIndicator()))
              : Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header section (Balance status, meal, time, kcal)
                      _buildHeader(model),
                      // Removed the yellow "Năng lượng" box with apple chart
                    ],
                  ),
                );
        }));
  }

  Widget _buildHeader(FoodCaloModel model) {
    // Sample data - replace with actual meal data from API
    String selectedDate = DateFormat('dd/MM').format(DateTime.now());
    String selectedDateTime = DateFormat('HH:mm').format(DateTime.now());
    String selectedStatus = 'Cân bằng'; // Get from model

    // Find meal with highest energy
    String selectedMeal = 'Bữa trưa';
    double maxEnergy = 0;
    if (model.mealDetails.isNotEmpty) {
      for (var meal in model.mealDetails) {
        if ((meal.value ?? 0) > maxEnergy) {
          maxEnergy = meal.value ?? 0;
          selectedMeal = meal.text!;
        }
      }
    }

    String selectedPoints = '8 điểm'; // TODO: Get from model when available
    String selectedKcal = '${maxEnergy.round()} Kcal';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selectedDateTime',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark,
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    margin: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFBFC6C6),
                    ),
                  ),
                  Text(
                    '$selectedDate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: R.color.color0xffE5E5E5,
                  width: 1,
                ),
                color: Colors.white,
              ),
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: R.color.color0xffE5E5E5, // Disabled for now
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  selectedStatus,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: R.color.greenGradientBottom,
                    height: 36 / 24,
                  ),
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: R.color.color0xffE5E5E5,
                  width: 1,
                ),
                color: Colors.white,
              ),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: R.color.color0xffE5E5E5, // Disabled for now
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$selectedMeal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: R.color.color0xff5E6566,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.only(left: 4, right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFBFC6C6),
              ),
            ),
            Text(
              '$selectedPoints',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.only(left: 4, right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFBFC6C6),
              ),
            ),
            Text(
              '$selectedKcal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  updateGoal(int goal) async {
    BotToast.showLoading();
    try {
      await FoodClient().updateTargetEnergy(goal);
      UserClient().fetchUser();
      _refresh();
      Observable.instance.notifyObservers([], notifyName: "goal_calo_changed");
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
    required this.progress,
    required this.startColor,
    required this.endColor,
    required this.width,
  }) : super();

  final double progress;
  final Color startColor;
  final Color endColor;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient = SweepGradient(
      startAngle: 3.2 * math.pi / 2,
      endAngle: 6.8 * math.pi / 2,
      tileMode: TileMode.repeated,
      colors: [startColor, startColor, endColor, endColor, startColor],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.butt // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (width / 2);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
