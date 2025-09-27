import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';

class BmiAISuggestionSession extends StatefulWidget {
  final int periodFilterType;
  final DateTime date;
  final String titleButton;

  const BmiAISuggestionSession({
    Key? key,
    required this.periodFilterType,
    required this.date,
    required this.titleButton,
  }) : super(key: key);

  @override
  State<BmiAISuggestionSession> createState() => _BmiAISuggestionSessionState();
}

class _BmiAISuggestionSessionState extends State<BmiAISuggestionSession> {
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
  void didUpdateWidget(BmiAISuggestionSession oldWidget) {
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark,
                  height: 21 / 15,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(R.drawable.ic_info, width: 20, height: 20),
            ],
          ),
          const SizedBox(height: 8),
          _buildContent(),
          if (!isLoading)
            InkWell(
              onTap: () async {
                // await _fetchExerciseHealthTrend();
                Observable.instance.notifyObservers([],
                    notifyName: Const.NAVIGATE_TO_CHAT_TAB);
              },
              child: Container(
                width: double.infinity,
                height: 42.h,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: R.color.color0xffE7FDFB,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.titleButton,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.greenGradientBottom,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return AILoadingTextWidget();
    } else if (hasError || (aiSuggestion == null || aiSuggestion!.isEmpty)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            R.drawable.error_AI,
            width: 44,
            height: 44,
          ),
          SizedBox(height: 8),
          Text(
            'Trợ lý Sống khoẻ đang nhận quá nhiều yêu cầu. Vui lòng thử lại sau nhé!',
            style: TextStyle(
              fontSize: 15,
              color: R.color.color0xff111515,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.start,
          ),
          // SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed: _fetchExerciseHealthTrend,
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: R.color.greenGradientBottom,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          //   child: Text(
          //     'Thử lại',
          //     style: TextStyle(color: R.color.white),
          //   ),
          // ),
        ],
      );
    } else {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 500),
        child: Text(
          aiSuggestion!,
          style: TextStyle(
            fontSize: 15,
            color: R.color.color0xff111515,
            height: 16 / 12,
            letterSpacing: 0.4,
          ),
        ),
      );
    }
  }
}
