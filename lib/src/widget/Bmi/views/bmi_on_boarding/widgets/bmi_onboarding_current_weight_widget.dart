import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class BmiOnboardingCurrentWeightWidget extends StatelessWidget {
  const BmiOnboardingCurrentWeightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "hkhjjk",
            style: R.style.largeTextStyle,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("hkhjjk",
                  style: R.style.largeTextStyle.copyWith(
                    color: R.color.mainColor,
                    fontWeight: FontWeight.w700
                  )),
              Icon(Icons.edit_square)
            ],
          ),
        ],
      ),
    );
  }
}
