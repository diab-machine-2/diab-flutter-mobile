import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

class BmiOverviewAIEvaluationSession extends StatelessWidget {
  const BmiOverviewAIEvaluationSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 8,),
              Icon(Icons.info_outline_rounded)
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            "Bạn đang thừa cân nhẹ. Nên đặt mục tiêu giảm về 55–60kg để cải thiện sức khỏe. Ăn uống lành mạnh, tập thể dục đều và giảm cân từ từ sẽ giúp duy trì hiệu quả bền vững.",
            style: R.style.normalTextStyle.neutral3,
          ),
          const SizedBox(
            height: 12,
          ),
          SecondaryRoundedButton(
            title: R.string.chat_with_AI.tr(),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
