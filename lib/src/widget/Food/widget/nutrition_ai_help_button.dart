import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';

class NutritionAIHelpButton extends StatelessWidget {
  const NutritionAIHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Observable.instance
          .notifyObservers([], notifyName: Const.NAVIGATE_TO_CHAT_TAB),
      child: Center(
        child: Text(
          R.string.chat_with_AI.tr(),
          style: TextStyle(
            color: R.color.mainColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: R.color.color0xffE1FAF8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        fixedSize: Size(double.infinity, 32),
        elevation: 0,
      ),
    );
  }
}
