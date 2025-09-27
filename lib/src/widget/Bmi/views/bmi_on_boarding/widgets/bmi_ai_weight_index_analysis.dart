import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_ai_suggestion_session.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_ai_suggestion.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/enum.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

class BmiAiWeightIndexAnalysis extends StatelessWidget {
  const BmiAiWeightIndexAnalysis({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) => current is BmiGetAIAnalysicState,
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    R.string.ai_suggestion_glucose.tr(),
                    style: R.style.semiBoldXLargeStyle,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Image.asset(
                    R.drawable.ic_info,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: state is BmiGetAIAnalysicState && state.data.isLoading
                    ? AILoadingTextWidget()
                    : Column(
                        children: [
                          Text(
                            _bmiBloc.aiAnalysicTrend,
                            style: R.style.normalTextStyle.neutral3,
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SecondaryRoundedButton(
                            title: R.string.chat_with_AI.tr(),
                            onPressed: () {
                              Observable.instance.notifyObservers([],
                                  notifyName: Const.NAVIGATE_TO_CHAT_TAB);
                            },
                          ),
                        ],
                      ),
              ),
            ],
          );
        });
  }
}
