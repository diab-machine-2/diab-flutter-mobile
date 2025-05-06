import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class FeatureItemWidget extends StatelessWidget {
  final PackageFeature feature;

  const FeatureItemWidget({
    Key? key,
    required this.feature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            R.drawable.ic_subscription_bullet,
            width: 20,
            height: 20,
          ),
          GapW(8),
          Expanded(
            child: feature.richText.isNotEmpty
                ? RichText(
                    text: TextSpan(
                      children: feature.richText,
                    ),
                  )
                : Text(
                    feature.text,
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
