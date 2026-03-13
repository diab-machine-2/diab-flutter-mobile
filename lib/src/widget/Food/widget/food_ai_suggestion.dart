import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/Food/widget/nutrition_ai_help_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodAISuggestion extends StatefulWidget {
  final int initialPeriodFilterType;

  const FoodAISuggestion({
    Key? key,
    this.initialPeriodFilterType = 1,
  }) : super(key: key);

  @override
  FoodAISuggestionState createState() => FoodAISuggestionState();
}

class FoodAISuggestionState extends State<FoodAISuggestion>
    with AutomaticKeepAliveClientMixin<FoodAISuggestion> {
  @override
  bool get wantKeepAlive => true;

  int periodFilterType = 1;
  String? _aiSuggestion;

  String _getDefaultSuggestion() {
    int days = 7;
    if (periodFilterType == 2) days = 14;
    if (periodFilterType == 3) days = 30;
    return "Trong $days ngày qua, bạn đã duy trì chế độ ăn khá cân bằng với lượng protein và rau củ hợp lý. Tuy nhiên, lượng carbohydrate hơi cao so với khuyến nghị. Nên giảm tinh bột và tăng lượng trái cây để bổ sung vitamin và chất xơ cho cơ thể.";
  }

  @override
  void initState() {
    super.initState();
    periodFilterType = widget.initialPeriodFilterType;
    _loadAISuggestion();
  }

  void _loadAISuggestion() async {
    setState(() {
      _aiSuggestion = null; // Show loading
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('latest_meal_score_suggestion');
      if (mounted) {
        setState(() {
          _aiSuggestion = (saved != null && saved.isNotEmpty)
              ? saved
              : _getDefaultSuggestion();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiSuggestion = _getDefaultSuggestion();
        });
      }
    }
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _loadAISuggestion();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Gợi ý trợ lý sống khỏe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(R.drawable.ic_info, width: 18, height: 18),
            ],
          ),
          const SizedBox(height: 8),
          if (_aiSuggestion == null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: AILoadingTextWidget(),
            )
          else if (_aiSuggestion!.isEmpty)
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC82221),
              ),
            )
          else ...[
            Text(
              _aiSuggestion!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 1.46,
              ),
            ),
            const SizedBox(height: 16),
            const NutritionAIHelpButton(),
          ],
        ],
      ),
    );
  }
}
