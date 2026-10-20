import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/shimmer_box.dart';

/// Shimmer placeholders for the Library tab, sized like the real sections
/// so content replaces them without a layout jump.

/// Owns the repeating animation shared by every [ShimmerBox] below it.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.builder});

  final Widget Function(Animation<double> animation) builder;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}

/// Horizontal row of lesson cards (260 × 262), as in "Dành cho bạn" and the
/// module sections. [withHeader] adds the section title bar.
class LessonCardRowSkeleton extends StatelessWidget {
  const LessonCardRowSkeleton({super.key, this.withHeader = false});

  final bool withHeader;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      builder: (animation) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (withHeader) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ShimmerBox(animation: animation, width: 140, height: 22),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: 262,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => _card(animation),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Animation<double> animation) => Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: R.color.grey_6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              animation: animation,
              height: 132,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            ShimmerBox(animation: animation, width: 70, height: 12),
            const SizedBox(height: 10),
            ShimmerBox(animation: animation, height: 14),
            const SizedBox(height: 8),
            ShimmerBox(animation: animation, width: 160, height: 14),
            const SizedBox(height: 14),
            ShimmerBox(animation: animation, width: 90, height: 12),
          ],
        ),
      );
}

/// Rows of the "Đề xuất" list: 80 × 80 thumbnail plus three text lines.
class LessonRecommendationSkeleton extends StatelessWidget {
  const LessonRecommendationSkeleton({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      builder: (animation) => Column(
        children: [
          for (var i = 0; i < rows; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: R.color.grey_6),
              ),
              child: Row(
                children: [
                  ShimmerBox(
                    animation: animation,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(animation: animation, width: 80, height: 12),
                        const SizedBox(height: 10),
                        ShimmerBox(animation: animation, height: 14),
                        const SizedBox(height: 8),
                        ShimmerBox(animation: animation, width: 120, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Two module sections shown while the main lesson list loads.
class LessonModulesSkeleton extends StatelessWidget {
  const LessonModulesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 2; i++)
          Container(
            color: R.color.white,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const LessonCardRowSkeleton(withHeader: true),
          ),
      ],
    );
  }
}
