import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/button_widget.dart';

class QuizResultWidget extends StatefulWidget {
  const QuizResultWidget({
    required this.rightAnswer,
    required this.totalQuiz,
    required this.minCompletePercent,
    required this.seeResultCallback,
    required this.retryCallback,
    required this.continueLearnCallback,
  });

  final int rightAnswer;
  final int totalQuiz;
  final double minCompletePercent;
  final VoidCallback seeResultCallback;
  final VoidCallback retryCallback;
  final VoidCallback continueLearnCallback;

  @override
  _QuizResultwidgetState createState() => _QuizResultwidgetState();
}

class _QuizResultwidgetState extends State<QuizResultWidget> {
  late final double rate;
  late final bool gotMaxRate;
  late final bool passQuiz;

  bool askForTryAgain = true;

  @override
  void initState() {
    super.initState();
    rate = (widget.rightAnswer / widget.totalQuiz) * 100;
    gotMaxRate = rate == 100;
    passQuiz = rate >= widget.minCompletePercent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                R.color.white,
                R.color.main_6,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  !passQuiz
                      ? R.drawable.img_learn_result_medium
                      : R.drawable.img_learn_result_high,
                  height: 150,
                ),
                const SizedBox(height: 10),
                Text(
                  R.string.completed_quiz.tr(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                      height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: !passQuiz
                          ? "Rất tiếc! Bạn cần trả lời đúng"
                          : "Bạn đã${gotMaxRate ? " xuất sắc" : ""} hoàn tất bài quiz và trả lời đúng ",
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        height: 1.375,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: !passQuiz
                                ? " ${(widget.minCompletePercent).round()}% "
                                : "${widget.rightAnswer}/${widget.totalQuiz}",
                            style: TextStyle(
                              color: R.color.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1.375,
                            )),
                        TextSpan(
                          text:
                              !passQuiz ? "để hoàn thành cấp độ này" : " câu!",
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            height: 1.375,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (gotMaxRate || !askForTryAgain)
                  _completeButtons()
                else
                  _notCompleteButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notCompleteButtons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text(
            R.string.challenge_yourself_again.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
                height: 1.37,
                letterSpacing: 0.4),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 128,
              child: ButtonWidget(
                height: 35,
                title: R.string.skip.tr(),
                textSize: 14,
                onPressed: () {
                  if (passQuiz) {
                    askForTryAgain = false;
                    setState(() {});
                  } else {
                    NavigationUtil.pop(context);
                    widget.continueLearnCallback();
                  }
                },
                backgroundColor: Colors.transparent,
                borderColor: R.color.accentColor,
                textColor: R.color.accentColor,
              ),
            ),
            Container(
              width: 128,
              child: ButtonWidget(
                  height: 35,
                  title: gotMaxRate
                      ? R.string.continue_learning.tr()
                      : R.string.accept.tr(),
                  textSize: 14,
                  onPressed: () {
                    NavigationUtil.pop(context);
                    widget.retryCallback();
                  }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _completeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 128,
          child: ButtonWidget(
            height: 35,
            title: R.string.see_the_answer.tr(),
            textSize: 14,
            onPressed: () {
              NavigationUtil.pop(context);
              widget.seeResultCallback();
            },
            backgroundColor: Colors.transparent,
            borderColor: R.color.accentColor,
            textColor: R.color.accentColor,
          ),
        ),
        Container(
          width: 128,
          child: ButtonWidget(
              height: 35,
              title: R.string.continue_learning.tr(),
              textSize: 14,
              onPressed: () {
                NavigationUtil.pop(context);
                widget.continueLearnCallback();
              }),
        ),
      ],
    );
  }
}
