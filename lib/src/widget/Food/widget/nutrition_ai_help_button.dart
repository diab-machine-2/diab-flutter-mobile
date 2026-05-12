import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

class NutritionAIHelpButton extends StatelessWidget {
  const NutritionAIHelpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: R.color.color0xffE7FDFB,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to chat or AI help
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: MediaQuery.of(context)
                          .textScaler
                          .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                    ),
                    child: Text(
                      R.string.chat_with_health_assistant.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: R.color.mainColor, // Teal text
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
