import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/model/ai_recommendation_result.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/components/ai_references_widget.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

class BmiOverviewAIEvaluationSession extends StatelessWidget {
  const BmiOverviewAIEvaluationSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) => current is BmiGetAIIndexAnalysicState,
        builder: (context, state) {
          return Container(
            decoration: R.decorationStyle.mediumRadiusCardStyles,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      R.string.ai_suggestion_glucose.tr(),
                      style: R.style.boldLargeStyle,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Icon(Icons.info_outline_rounded)
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
                              _bmiBloc.aiAnalysicWeightRecord?.recommendation ?? '',
                              style: R.style.normalTextStyle.neutral3,
                              textAlign: TextAlign.justify,
                            ),
                            AiReferencesWidget(references: _bmiBloc.aiAnalysicWeightRecord?.references ?? []),
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
            ),
          );
        });
  }
}
