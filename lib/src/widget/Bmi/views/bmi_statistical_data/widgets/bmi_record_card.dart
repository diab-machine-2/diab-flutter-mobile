import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';

class BmiRecordCard extends StatelessWidget {
  const BmiRecordCard({
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text.rich(
                    TextSpan(text: "70 ", style: R.style.alertTitle, children: [
                      TextSpan(
                        text: "kg",
                        style: R.style.normalTextStyle,
                      )
                    ]),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.neutral5),
                    width: 8,
                    height: 8,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    "7:30",
                    style: R.style.normalTextStyle,
                  )
                ],
              ),
              Text(
                "Thua can",
                style: R.style.alertTitle,
              )
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: "BMI ",
                  style: R.style.normalTextStyle,
                  children: [
                    TextSpan(
                      text: "25.0",
                      style: R.style.normalTextStyle,
                    )
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: "BMI ",
                  style: R.style.normalTextStyle,
                  children: [
                    TextSpan(
                      text: "25.0",
                      style: R.style.normalTextStyle,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
