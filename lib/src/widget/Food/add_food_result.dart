import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/ai_recommendation_result.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/widget/components/ai_references_widget.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'food_result.dto.dart';
import 'widget/meal_items_display_widget.dart';
import 'widget/nutrition_ai_help_button.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';

class PageAddFoodResult extends StatefulWidget {
  const PageAddFoodResult({super.key, required this.data});
  final FoodResultDto data;

  @override
  State<PageAddFoodResult> createState() => _PageAddFoodResultState();
}

class _PageAddFoodResultState extends State<PageAddFoodResult> {
  AiRecommendationResult? _aiResult;

  bool _haveEditNote = false;
  // ignore: unused_field
  late String _note = widget.data.note ?? '';
  // ignore: unused_field
  List<dynamic> _files = [];

  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controllerNote;

  @override
  void initState() {
    _controllerNote = TextEditingController(text: widget.data.note ?? '');
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  void _loadData() async {
    final data = widget.data;
    _files = data.images;
    _aiResult = data.healthRecommendation != null
        ? AiRecommendationResult(
            recommendation: data.healthRecommendation!,
            references: data.references,
          )
        : null;
    if (mounted) {
      setState(() {});
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
    // Finish the manual/capture flow and return to existing food detail screen.
    bool foundDetailRoute = false;
    Navigator.popUntil(context, (route) {
      final isDetail = route.settings.name == NavigatorName.detail_food;
      if (isDetail) {
        foundDetailRoute = true;
      }
      return isDetail || route.isFirst;
    });

    if (!foundDetailRoute && mounted) {
      Navigator.pushNamed(context, NavigatorName.detail_food);
    }
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
                      child: Column(
                        children: [
                          _foodResultSection(),
                          const SizedBox(height: 16),
                          SectionAddNote(
                            focusNode: _focusNode,
                            controllerNote: _controllerNote,
                            maxMedia: 5,
                            initialFiles: _files,
                            noteTitle: R.string.ghi_chu.tr(),
                            horizontalPadding: 16,
                          ),
                        ],
                      ),
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
    final appLang = AppPreference().appLanguage;
    final localeId = appLang == Const.VI ? 'vi' : 'en';
    final formattedDateTime =
        DateFormat('EEE, dd/MM/yyyy', localeId).format(widget.data.dateTime);
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
                text: R.string.today_you_achieved.tr(),
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
              timeFrame: widget.data.timeFrame,
              score: widget.data.score ?? 0,
              balanceStatus: widget.data.localizedBalanceStatus,
            ),
          ),

          const SizedBox(height: 32),
          // Nutrition Distribution
          Text(
            R.string.phan_bo_dinh_duong.tr(),
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
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context)
                      .textScaler
                      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                ),
                child: Text(
                  R.string.ai_health_assistant_suggestion.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: R.color.textDark,
                    height: 21 / 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_aiResult == null || _aiResult!.isEmpty)
            Center(
              child: Text(
                R.string.an_error_occurred.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: R.color.attentionText,
                ),
              ),
            )
          else ...[
            Text(
              _aiResult!.recommendation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 20 / 14,
              ),
            ),
            AiReferencesWidget(references: _aiResult!.references),
            const SizedBox(height: 16),
            NutritionAIHelpButton(),
            // Meal items display
            MealItemsDisplayWidget(data: widget.data),
          ],
        ],
      ),
    );
  }

  Color _parseHexColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      final hexStr = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexStr', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Widget _nutritionDistributionBars() {
    final np = widget.data.nutritionPercent;
    final nc = widget.data.nutritionColors;
    final defaultColor = Color(0xFFFFA726);

    final items = [
      {
        'label': R.string.tinh_bot.tr(),
        'percent': np?['carb'] ?? 0,
        'color': _parseHexColor(nc?['carb'], defaultColor)
      },
      {
        'label': R.string.protein_nutrient.tr(),
        'percent': np?['protein'] ?? 0,
        'color': _parseHexColor(nc?['protein'], defaultColor)
      },
      {
        'label': R.string.fat_nutrient.tr(),
        'percent': np?['fat'] ?? 0,
        'color': _parseHexColor(nc?['fat'], defaultColor)
      },
      {
        'label': R.string.vegetable_nutrient.tr(),
        'percent': np?['vegetable'] ?? 0,
        'color': _parseHexColor(nc?['vegetable'], defaultColor)
      },
      {
        'label': R.string.nhom_hoa_qua.tr(),
        'percent': np?['fruit'] ?? 0,
        'color': _parseHexColor(nc?['fruit'], defaultColor)
      },
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
              R.string.an_bao_nhieu_la_du.tr(),
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
        Container(
          margin: EdgeInsets.only(right: 4),
          width: 80,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context)
                  .textScaler
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: R.color.textDark,
                fontWeight: FontWeight.w400,
              ),
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
                widthFactor: min(percent / 100, 1.0),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 13,
                      color: R.color.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomSection() {
    return Row(
      children: [
        // Nút Chia sẻ (bên trái)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(200),
              border: Border.all(color: Color(0xFF008479), width: 1.5),
            ),
            child: ElevatedButton(
              onPressed: _shareFood,
              child: Text(R.string.share.tr(),
                  style: TextStyle(
                      color: Color(0xFF008479),
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
          ),
        ),
        const SizedBox(width: 12),
        // Nút Hoàn tất (bên phải)
        Expanded(
          child: Container(
            height: 48,
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
              child: Text(R.string.hoan_thanh.tr(),
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
          ),
        ),
      ],
    );
  }

  /// Chia sẻ thông tin bữa ăn
  void _shareFood() {
    final data = widget.data;
    final StringBuffer shareContent = StringBuffer();

    shareContent.writeln('🍽️ Bữa ăn của tôi');
    shareContent
        .writeln('📅 ${DateFormat('dd/MM/yyyy HH:mm').format(data.dateTime)}');
    shareContent.writeln('⏰ ${data.timeFrame}');
    shareContent.writeln('');

    // Thêm thông tin từng món
    for (var food in data.foods) {
      final portion = food.portion ?? 1;
      final unit = food.unit ?? 'phần';
      final calorie = ((food.calorie ?? 0) * portion).round();
      shareContent.writeln('• ${food.name} - $portion $unit ($calorie kcal)');
    }

    shareContent.writeln('');
    shareContent.writeln('🔥 Tổng: ${data.totalCalories.toInt()} Kcal');
    shareContent.writeln('🎯 Mục tiêu: ${data.goalCalories.toInt()} Kcal');
    shareContent.writeln(
        '📊 Đánh giá: ${data.balanceStatus ?? "Chưa xác định"} (${data.score ?? 0}/10)');

    // TODO: Implement share functionality with share_plus
    // Share.share(shareContent.toString());

    // Tạm thời show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép nội dung bữa ăn'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _CircularNutritionGauge extends StatelessWidget {
  final double totalCalories;
  final String timeFrame;
  final int score;
  final String balanceStatus;

  const _CircularNutritionGauge({
    required this.totalCalories,
    required this.timeFrame,
    required this.score,
    required this.balanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidScore = score > 0;
    // Arc uses the same 0–100 scale as RadialAxis; map score (0–10) so the
    // ring matches the centered X/10 (calorie ratio is already in the header).
    final progressValue = hasValidScore ? min(score * 10.0, 100.0) : 0.0;
    final isBalanced = balanceStatus == R.string.can_bang.tr();
    Color arcColor = isBalanced ? Color(0xFF4CAF50) : Color(0xFFFFA726);

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
                endValue: progressValue,
                color: arcColor,
                startWidth: 12,
                endWidth: 12,
              ),
              GaugeRange(
                startValue: progressValue,
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
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(context)
                            .textScaler
                            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                      ),
                      child: Text(
                        balanceStatus,
                        style: TextStyle(
                          fontSize: 18,
                          color: arcColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(context)
                            .textScaler
                            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                      ),
                      child: Text(
                        '$timeFrame - ${totalCalories.toInt()} kcal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
