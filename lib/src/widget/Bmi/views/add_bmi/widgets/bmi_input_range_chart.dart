import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class BmiInputRangeChart extends StatelessWidget {
  final List<double> thresholds;
  final List<Color> colors;
  final double currentValue;
  final Widget? markerWidget;
  final double barHeight;
  final double gap;
  final double borderRadius;
  final TextStyle? thresholdTextStyle;

  const BmiInputRangeChart({
    super.key,
    required this.thresholds,
    required this.colors,
    required this.currentValue,
    this.markerWidget,
    this.barHeight = 20,
    this.gap = 0,
    this.borderRadius = 6,
    this.thresholdTextStyle,
  });

  static const markerSize = 24.0;
  static const arrowSize = 24.0;

  @override
  Widget build(BuildContext context) {
    assert(thresholds.isNotEmpty, 'thresholds cannot be empty');

    final sortedThresholds = List<double>.from(thresholds)..sort();
    final textStyle =
        thresholdTextStyle ?? const TextStyle(fontSize: 12, color: Colors.black);

    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth =
          (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
              ? constraints.maxWidth
              : 300.0;

      final sections = sortedThresholds.length + 1;
      final segmentWidth =
          (totalWidth - gap * (sections - 1)) / sections; // mỗi ô cách đều

      // màu cho từng đoạn
      final segColors = List<Color>.generate(sections,
          (i) => (i < colors.length ? colors[i] : Colors.grey.shade300));

      /// --- 🧠 TÍNH TỌA ĐỘ MARKER ---
      double computeMarkerX() {
        final first = sortedThresholds.first;
        final last = sortedThresholds.last;

        // nhỏ hơn min → ở giữa ô đầu
        if (currentValue <= first) {
          return segmentWidth / 2;
        }

        // lớn hơn max → ở giữa ô cuối
        if (currentValue >= last) {
          return (sections - 1) * (segmentWidth + gap) + segmentWidth / 2;
        }

        // nằm giữa các mốc → tính tỷ lệ thực trong đoạn đó
        for (int i = 0; i < sortedThresholds.length - 1; i++) {
          final a = sortedThresholds[i];
          final b = sortedThresholds[i + 1];
          if (currentValue >= a && currentValue <= b) {
            final ratio = (currentValue - a) / (b - a);
            final startX = (i + 1) * (segmentWidth + gap);
            final endX = startX + segmentWidth + gap;
            return startX + ratio * (endX - startX) - gap / 2;
          }
        }

        // fallback
        return totalWidth / 2;
      }

      final markerCenterX = computeMarkerX();
      final markerLeft =
          (markerCenterX - markerSize / 2).clamp(0.0, totalWidth - markerSize);

      /// --- BUILD CHART ---
      final bar = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(sections * 2 - 1, (i) {
          if (i.isOdd) return SizedBox(width: gap);
          final idx = i ~/ 2;
          final radius = BorderRadius.horizontal(
            left: idx == 0 ? Radius.circular(borderRadius) : Radius.zero,
            right:
                idx == sections - 1 ? Radius.circular(borderRadius) : Radius.zero,
          );
          return Container(
            width: segmentWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: segColors[idx],
              borderRadius: radius,
            ),
          );
        }),
      );

      final labels = List.generate(sortedThresholds.length, (i) {
        final x = (i + 1) * (segmentWidth + gap) + textStyle.fontSize! / 2;
        return Positioned(
          left: x - 12,
          top: markerSize + barHeight + 8,
          child: Text(
            _formatThreshold(sortedThresholds[i]),
            style: textStyle,
          ),
        );
      });

      return SizedBox(
        height: markerSize + barHeight + 30,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // marker
            Positioned(
              left: markerLeft,
              top: 0,
              width: markerSize,
              child: Row(
                children: [
                  markerWidget ??
                      Icon(Icons.arrow_drop_down, size: arrowSize, color: Colors.black),
                  Text("BMI", style: R.style.smallTextStyle,)
                ],
              ),
            ),
            // labels
            ...labels,
            
            // bar
            Positioned(
              top: markerSize,
              left: 0,
              right: 0,
              child: bar,
            ),
          ],
        ),
      );
    });
  }

  String _formatThreshold(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    if ((v * 10) % 1 == 0) return v.toStringAsFixed(1);
    return v.toString();
  }
}

