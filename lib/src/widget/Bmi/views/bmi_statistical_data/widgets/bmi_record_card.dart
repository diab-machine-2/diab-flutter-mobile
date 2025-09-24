import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';

class BmiRecordCard extends StatelessWidget {
  const BmiRecordCard({
    super.key,
    required this.data,
  });

  final BmiGetWeightRecord data;

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
                    TextSpan(
                        text: "${data.weight} ",
                        style: R.style.boldXXLargeStyle,
                        children: [
                          TextSpan(
                            text: "kg",
                            style: R.style.largeTextStyle.neutral3,
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
                    "${data.date}",
                    style: R.style.largeTextStyle.neutral3,
                  )
                ],
              ),
              Text(
                data.bmiText ?? "--",
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
                  style: R.style.largeTextStyle.neutral3,
                  children: [
                    TextSpan(
                      text: "${data.bmi} cm",
                      style: R.style.boldLargeStyle,
                    )
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: "Vong eo ",
                  style: R.style.largeTextStyle.neutral3,
                  children: [
                    TextSpan(
                      text: "${data.waist} cm",
                      style: R.style.boldLargeStyle,
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
