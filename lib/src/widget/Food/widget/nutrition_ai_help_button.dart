import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class NutritionAIHelpButton extends StatelessWidget {
  const NutritionAIHelpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF0EA5E9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to chat or AI help
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFF0EA5E9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thiết lập mục tiêu Kcal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0EA5E9),
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
