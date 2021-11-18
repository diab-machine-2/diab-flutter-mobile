import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CustomProgressBarWidget extends StatelessWidget {
  const CustomProgressBarWidget(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress == 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          alignment: Alignment.centerLeft,
          height: 6,
          width: double.infinity,
          color: R.color.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(200),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  R.color.color0xff004E47.withOpacity(0.3),
                  R.color.mainColor,
                ],
              ),
            ),
            width: constraint.maxWidth * progress,
          ),
        );
      },
    );
  }
}
