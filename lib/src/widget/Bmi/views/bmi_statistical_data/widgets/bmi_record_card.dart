import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';

class BmiRecordCard extends StatelessWidget {
  const BmiRecordCard({
    super.key,
    required this.data,
    this.onTap,
  });

  final BmiGetWeightRecord data;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    int dateInTimestamp = (data.date ?? 0) * 1000;
    String timeInText = DateUtil.parseDateToString(
      DateTime.fromMillisecondsSinceEpoch(dateInTimestamp),
      Const.HOUR_MIN,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
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
                      timeInText,
                      style: R.style.largeTextStyle.neutral3,
                    )
                  ],
                ),
                Text(
                  data.bmiText ?? "--",
                  style:
                      R.style.boldLargeStyle.copyWith(color: data.bmiColor),
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
                        text: "${data.bmi}",
                        style: R.style.boldLargeStyle.neutral3,
                      )
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: "${R.string.waist.tr()} ",
                    style: R.style.largeTextStyle.neutral3,
                    children: [
                      TextSpan(
                        text: (data.waist == null || data.waist == 0)
                            ? "--"
                            : "${data.waist} cm",
                        style: R.style.boldLargeStyle.neutral3,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
