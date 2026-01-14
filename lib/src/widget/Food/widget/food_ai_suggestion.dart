import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/Food/widget/nutrition_ai_help_button.dart';

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

  final _bloc = FoodBloc();
  late BuildContext currentContext;
  int periodFilterType = 1;
  String? _aiSuggestion;

  @override
  void initState() {
    super.initState();
    periodFilterType = widget.initialPeriodFilterType;
    _loadAISuggestion();
  }

  void _loadAISuggestion() {
    // TODO: Uncomment khi backend đã tạo endpoint /App/Diet/Analysis/HealthTrend
    // final currentDateTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    // _bloc.add(FetchDietAnalysis(
    //   currentDateTime: currentDateTime,
    //   periodFilterType: periodFilterType.toString(),
    // ));

    // HARDCODE TEXT TẠM ĐỂ TEST UI
    setState(() {
      _aiSuggestion =
          "Trong 7 ngày qua, bạn đã duy trì chế độ ăn khá cân bằng với lượng protein và rau củ hợp lý. Tuy nhiên, lượng carbohydrate hơi cao so với khuyến nghị. Nên giảm tinh bột và tăng lượng trái cây để bổ sung vitamin và chất xơ cho cơ thể.";
    });
  }

  void reloadData(int periodFilter) {
    setState(() {
      periodFilterType = periodFilter;
      // Reset và set lại hardcoded text
      _aiSuggestion =
          "Trong $periodFilter ngày qua, bạn đã duy trì chế độ ăn khá cân bằng với lượng protein và rau củ hợp lý. Tuy nhiên, lượng carbohydrate hơi cao so với khuyến nghị. Nên giảm tinh bột và tăng lượng trái cây để bổ sung vitamin và chất xơ cho cơ thể.";
    });
    // _loadAISuggestion(); // Comment tạm
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>.value(
      value: _bloc,
      child: BlocBuilder<FoodBloc, FoodState>(
        builder: (BuildContext context, FoodState state) {
          currentContext = context;

          if (state is FoodDietAnalysisLoaded) {
            _aiSuggestion = state.dietAnalysis;
          }

          if (state is FoodError) {
            print('❌ Food AI Suggestion Error: ${state.message}');
            _aiSuggestion = ''; // Show error
          }

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
        },
      ),
    );
  }
}
