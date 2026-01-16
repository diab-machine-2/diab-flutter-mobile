import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'food_result.dto.dart';
import 'widget/meal_items_display_widget.dart';
import 'widget/nutrition_ai_help_button.dart';

class PageAddFoodResult extends StatefulWidget {
  const PageAddFoodResult({super.key, required this.data});
  final FoodResultDto data;

  @override
  State<PageAddFoodResult> createState() => _PageAddFoodResultState();
}

class _PageAddFoodResultState extends State<PageAddFoodResult> {
  String? _aiResult;

  bool _haveEditNote = false;
  late String _note = widget.data.note ?? '';
  List<dynamic> _files = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    final data = widget.data;
    _files = data.images ?? [];

    // Tạm thời comment AI analysis vì chưa có API
    // final aiResult = shouldFetchNewData
    //     ? await FoodClient()
    //         .fetchMealAnalysis(widget.data.id)
    //         .catchError((e, s) {
    //         TrackingManager.recordError(e, s);
    //         return null;
    //       })
    //     : data.healthRecommendation;

    _aiResult = data.healthRecommendation ?? _getDefaultRecommendation();
    if (mounted) {
      setState(() {});
    }
  }

  String _getDefaultRecommendation() {
    // Placeholder recommendation based on balance status
    if (widget.data.balanceStatus == 'Cân bằng') {
      return 'Bữa ăn này khá cân bằng! Bạn đã cung cấp đủ năng lượng và dinh dưỡng cần thiết cho cơ thể. Hãy tiếp tục duy trì chế độ ăn uống lành mạnh này.';
    } else {
      return 'Bữa cơm này còn thiếu cân bằng. Để nhẹ người hơn, bạn có thể bỏ chút cháo, gà chiên và bi lược. Đề nghệ người hơn, bạn có thể bỏ chút phần miếng gà chiên sang gà nướng hoặc cá, và kết bữa bằng trái cây tươi. Nếu gà kèm nướng hoặc chiên không đều giúp giảm bớt mỡ mà vẫn giữ ngon.';
    }
  }

  void _doComplete() async {
    try {
      BotToast.showLoading();
      if (_haveEditNote) {
        // TODO: Update note and images if edited
      }
      Observable.instance.notifyObservers([], notifyName: "food_change_data");
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      BotToast.closeAllLoading();
    }

    // Navigate to food detail screen
    Navigator.pop(context);
    Navigator.pushNamed(context, NavigatorName.detail_food);
  }

  void _doBack() {
    Observable.instance.notifyObservers([], notifyName: "food_change_data");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _appBarSection(),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 100),
                      physics: const ClampingScrollPhysics(),
                      child: _foodResultSection(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 8 + MediaQuery.of(context).padding.bottom / 2,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: _bottomSection(),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBarSection() {
    String formattedDateTime =
        DateFormat('EEEE, dd/MM/yyyy', 'vi').format(widget.data.dateTime);
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        formattedDateTime,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: R.color.white),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: _doBack,
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                // TODO: Show guide
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _foodResultSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Calories achieved
          const SizedBox(height: 8),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Hôm nay bạn đã đạt ',
                style: TextStyle(
                  fontSize: 15,
                  color: R.color.textDark,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text:
                        '${widget.data.totalCalories.toInt()}/${widget.data.goalCalories.toInt()}',
                    style: TextStyle(
                      fontSize: 15,
                      color: R.color.greenGradientBottom,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' Kcal',
                    style: TextStyle(
                      fontSize: 15,
                      color: R.color.textDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Circular Chart
          Container(
            height: 220,
            width: double.infinity,
            child: _CircularNutritionGauge(
              totalCalories: widget.data.totalCalories,
              goalCalories: widget.data.goalCalories,
              timeFrame: widget.data.timeFrame,
              score: widget.data.score ?? 6,
              balanceStatus: widget.data.balanceStatus ?? 'Chưa cân bằng',
            ),
          ),

          const SizedBox(height: 32),
          // Nutrition Distribution
          Text(
            'Phân bổ dinh dưỡng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: R.color.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _nutritionDistributionBars(),

          const SizedBox(height: 24),
          // AI Suggestion
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF0EA5E9), size: 20),
              const SizedBox(width: 6),
              Text(
                'Gợi ý từ Trợ lý Sống khoẻ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 21 / 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_aiResult == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CircularProgressIndicator(),
            )
          else if (_aiResult!.isEmpty)
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC82221),
              ),
            )
          else ...[
            Text(
              _aiResult ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 20 / 14,
              ),
            ),
            const SizedBox(height: 16),
            NutritionAIHelpButton(),
            // Meal items display
            MealItemsDisplayWidget(data: widget.data),
          ],
        ],
      ),
    );
  }

  Widget _nutritionDistributionBars() {
    final items = [
      {'label': 'Tinh bột', 'percent': 0, 'color': Color(0xFFFFA726)},
      {'label': 'Chất đạm', 'percent': 0, 'color': Color(0xFFFFA726)},
      {'label': 'Chất béo', 'percent': 0, 'color': Color(0xFFFFA726)},
      {'label': 'Rau củ', 'percent': 0, 'color': Color(0xFFFFA726)},
      {'label': 'Hoa quả', 'percent': 0, 'color': Color(0xFFFFA726)},
    ];

    return Column(
      children: [
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _nutritionBar(
                label: item['label'] as String,
                percent: item['percent'] as int,
                color: item['color'] as Color,
              ),
            )),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: R.color.primaryGreyColor),
            const SizedBox(width: 4),
            Text(
              'Ăn bao nhiêu là đủ',
              style: TextStyle(
                fontSize: 13,
                color: R.color.primaryGreyColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _nutritionBar({
    required String label,
    required int percent,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: R.color.textDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: min(percent / 100, 1.3),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: percent > 100 ? Color(0xFFEF5350) : R.color.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: R.color.mainColor,
        borderRadius: BorderRadius.circular(200),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.centerRight,
          colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
        ),
      ),
      child: ElevatedButton(
        onPressed: _doComplete,
        child: Text(R.string.completed.tr(),
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
        ),
      ),
    );
  }
}

class _CircularNutritionGauge extends StatelessWidget {
  final double totalCalories;
  final double goalCalories;
  final String timeFrame;
  final int score;
  final String balanceStatus;

  const _CircularNutritionGauge({
    required this.totalCalories,
    required this.goalCalories,
    required this.timeFrame,
    required this.score,
    required this.balanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (totalCalories / goalCalories) * 100;
    Color arcColor =
        balanceStatus == 'Cân bằng' ? Color(0xFF4CAF50) : Color(0xFFFFA726);

    return Center(
      child: SfRadialGauge(
        backgroundColor: Colors.white,
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 135,
            endAngle: 405,
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0,
              thicknessUnit: GaugeSizeUnit.logicalPixel,
            ),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: min(percent, 100),
                color: arcColor,
                startWidth: 12,
                endWidth: 12,
              ),
              GaugeRange(
                startValue: min(percent, 100),
                endValue: 100,
                color: Color(0xFFE6ECF1),
                startWidth: 12,
                endWidth: 12,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      balanceStatus,
                      style: TextStyle(
                        fontSize: 18,
                        color: arcColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$timeFrame - ${totalCalories.toInt()} kcal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        text: '$score',
                        style: TextStyle(
                          fontSize: 48,
                          color: R.color.textDark,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Viga',
                        ),
                        children: [
                          TextSpan(
                            text: '/10',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
                positionFactor: 0,
                angle: 90,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
