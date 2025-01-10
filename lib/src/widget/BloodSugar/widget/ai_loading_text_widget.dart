import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class AILoadingTextWidget extends StatelessWidget {
  const AILoadingTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF111515),
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Đang phân tích chỉ số của bạn',
            speed: const Duration(milliseconds: 60),
          ),
        ],
        totalRepeatCount: 5,
      ),
    );
  }
}
