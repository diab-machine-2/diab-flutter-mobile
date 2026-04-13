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

  int periodFilterType = 1;

  Future<String> _resolveAdvice(FoodNutritionOverviewLoaded state) async {
    final api = state.aiAdvice;
    if (api != null && api.isNotEmpty) return api;
    return '';
  }

  @override
  void initState() {
    super.initState();
    periodFilterType = widget.initialPeriodFilterType;
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading || state is FoodInitial) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý từ Trợ lý Sống khoẻ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: R.color.color0xff111515,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(R.drawable.ic_info, width: 18, height: 18),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: AILoadingTextWidget(),
                ),
              ],
            ),
          );
        }

        if (state is FoodError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý từ Trợ lý Sống khoẻ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: R.color.color0xff111515,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(R.drawable.ic_info, width: 18, height: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFC82221),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is FoodNutritionOverviewLoaded) {
          return FutureBuilder<String>(
            key: ValueKey(
                '${state.range}_${periodFilterType}_${state.aiAdvice ?? ''}_${state.nutrientPercent.hashCode}'),
            future: _resolveAdvice(state),
            builder: (context, snapshot) {
              final text = snapshot.data;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Gợi ý từ Trợ lý Sống khoẻ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: R.color.color0xff111515,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Image.asset(R.drawable.ic_info, width: 18, height: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (text == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: AILoadingTextWidget(),
                      )
                    else if (text.isEmpty)
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
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff111515,
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
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Gợi ý từ Trợ lý Sống khoẻ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: R.color.color0xff111515,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(R.drawable.ic_info, width: 18, height: 18),
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: AILoadingTextWidget(),
              ),
            ],
          ),
        );
      },
    );
  }
}
