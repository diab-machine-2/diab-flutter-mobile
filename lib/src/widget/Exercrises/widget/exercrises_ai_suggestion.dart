import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';

class ExercrisesAISuggestion extends StatefulWidget {
  final int periodFilterType;
  final DateTime date;

  const ExercrisesAISuggestion({
    Key? key,
    required this.periodFilterType,
    required this.date,
  }) : super(key: key);

  @override
  State<ExercrisesAISuggestion> createState() => _ExercrisesAISuggestionState();
}

class _ExercrisesAISuggestionState extends State<ExercrisesAISuggestion> {
  bool isLoading = true;
  String? aiSuggestion;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchExerciseHealthTrend();
  }

  @override
  void didUpdateWidget(ExercrisesAISuggestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch data if periodFilterType or date changed
    if (oldWidget.periodFilterType != widget.periodFilterType ||
        oldWidget.date != widget.date) {
      _fetchExerciseHealthTrend();
    }
  }

  Future<void> _fetchExerciseHealthTrend() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    try {
      final result = await AppRepository().getExerciseHealthTrend(
        (widget.date.millisecondsSinceEpoch ~/ 1000).toString(),
        widget.periodFilterType,
      );

      result.when(
        success: (data) {
          if (mounted) {
            setState(() {
              aiSuggestion = data;
              isLoading = false;
            });
          }
        },
        failure: (error) {
          if (mounted) {
            setState(() {
              hasError = true;
              errorMessage = error.toString();
              isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // AI result
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.ai_suggestion_glucose.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 21 / 15,
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(R.drawable.ic_speak_text, width: 24, height: 24),
            ],
          ),
          const SizedBox(height: 8),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: AILoadingTextWidget(),
      );
    } else if (hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra khi phân tích dữ liệu. Vui lòng thử lại sau.',
            style: TextStyle(
              fontSize: 14,
              color: R.color.deepOrange,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchExerciseHealthTrend,
            style: ElevatedButton.styleFrom(
              backgroundColor: R.color.greenGradientBottom,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Thử lại',
              style: TextStyle(color: R.color.white),
            ),
          ),
        ],
      );
    } else if (aiSuggestion == null || aiSuggestion!.isEmpty) {
      return Text(
        'Chưa có đủ dữ liệu để phân tích. Hãy thêm hoạt động vận động để nhận được gợi ý tốt hơn.',
        style: TextStyle(
          fontSize: 14,
          color: R.color.textDark,
        ),
      );
    } else {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 500),
        child: Text(
          aiSuggestion!,
          style: TextStyle(
            fontSize: 14,
            color: R.color.primaryGreyColor,
            height: 16 / 12,
          ),
        ),
      );
    }
  }
}
