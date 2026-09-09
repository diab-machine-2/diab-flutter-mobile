import 'package:flutter/material.dart';

/// A single animated shimmer placeholder block. Pass the same [animation]
/// (an owning widget's repeating [AnimationController]) to every [ShimmerBox]
/// in a composition so their sweeps stay in sync.
class ShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    Key? key,
    required this.animation,
    this.width,
    this.height = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-3.0 + 6.0 * t, 0),
              end: Alignment(-1.0 + 6.0 * t, 0),
              colors: const [
                Color(0xFFE4E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE4E7EB),
              ],
            ),
          ),
        );
      },
    );
  }
}
