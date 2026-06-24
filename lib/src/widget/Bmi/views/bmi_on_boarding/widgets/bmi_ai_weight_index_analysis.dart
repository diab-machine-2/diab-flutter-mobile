import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/components/ai_references_widget.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

class BmiAiWeightIndexAnalysis extends StatelessWidget {
  // Follows the same pattern as BloodSugar's _sectionAIHelp:
  // loading → loading widget, null/empty → error text, content → recommendation + references + CTA
  static const Color _errorColor = Color(0xFFC82221);
  static const double _aiHelpVerticalGap = 20;
  const BmiAiWeightIndexAnalysis({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) =>
            current is BmiGetAIAnalysicState ||
            current is BmiGetWeightIndexListState ||
            (current is BmiDataChangedState &&
                current.event == BmiDataChangeEvent.selectedPointChanged),
        builder: (context, state) {
          if (_bmiBloc.selectedPointChart == null) return const SizedBox();

          return Column(
            children: [
              Row(
                children: [
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(context)
                            .textScaler
                            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)),
                    child: Text(
                      R.string.ai_suggestion_glucose.tr(),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111515),
                        fontFamily: R.font.sfpro,
                        letterSpacing: 0.036,
                      ),
                    ),
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
              _buildBody(_bmiBloc, state),
            ],
          );
        });
  }

  Widget _buildBody(BmiBloc bloc, BmiState state) {
    // Determine the inner child
    Widget inner;
    if (state is BmiGetAIAnalysicState && state.data.isLoading) {
      inner = const AILoadingTextWidget();
    } else {
      final recommendation = bloc.aiAnalysicTrend?.recommendation;
      if (recommendation == null || recommendation.isEmpty) {
        // Error or empty recommendation — same pattern as BloodSugar's _sectionAIHelp
        inner = Text(
          'Có lỗi xảy ra',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: _errorColor,
          ),
        );
      } else {
        // Content state
        inner = Column(
          children: [
            Text(
              recommendation,
              style: R.style.normalTextStyle.neutral3,
              textAlign: TextAlign.justify,
            ),
            AiReferencesWidget(
                references: bloc.aiAnalysicTrend?.references ?? []),
            const SizedBox(height: _aiHelpVerticalGap),
            SecondaryRoundedButton(
              title: R.string.chat_with_AI.tr(),
              onPressed: () {
                Observable.instance.notifyObservers([],
                    notifyName: Const.NAVIGATE_TO_CHAT_TAB);
              },
            ),
          ],
        );
      }
    }

    // AnimatedSwitcher for smooth loading→error/content transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      child: inner,
    );
  }
}
