import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';
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
                  Icon(Icons.info_outline_rounded)
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                _bmiBloc.aiAnalysicTrend,
                style: R.style.normalTextStyle.neutral3,
              ),
              const SizedBox(
                height: 24,
              ),
              SecondaryRoundedButton(
                title: R.string.chat_with_AI.tr(),
                onPressed: () {},
              ),
            ],
          );
        });
  }
}