import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/text_styles_extension.dart';

import '../../../../res/R.dart';

class AILoadingTextWidget extends StatelessWidget {
  const AILoadingTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DefaultTextStyle(
        textAlign: TextAlign.start,
        // style: TextStyle(
        //   fontSize: 15,
        //   fontWeight: FontWeight.w400,
        //   color: R.color.color0xffEDEEEE,
        //   letterSpacing: 0.4,
        // ),
        style: R.style.normalTextStyle.neutral4,
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              R.string.analyzing_your_index.tr(),
              speed: const Duration(milliseconds: 60),
            ),
          ],
          totalRepeatCount: 5,
        ),
      ),
    );
  }
}
