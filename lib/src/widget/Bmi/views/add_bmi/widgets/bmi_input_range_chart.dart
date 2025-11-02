// import 'package:flutter/material.dart';
// import 'package:medical/res/R.dart';
// import 'package:medical/res/text_styles_extension.dart';

// class BmiInputRangeChart extends StatelessWidget {
//   final List<double> thresholds;
//   final List<Color> colors;
//   final double currentValue;
//   final Widget? markerWidget; // nếu null dùng icon mặc định
//   final double barHeight;
//   final double gap; // khoảng trắng giữa các ô
//   final double borderRadius;
//   final TextStyle? thresholdTextStyle;

//   const BmiInputRangeChart({
//     super.key,
//     required this.thresholds,
//     required this.colors,
//     required this.currentValue,
//     this.markerWidget,
//     this.barHeight = 20,
//     this.gap = 4,
//     this.borderRadius = 6,
//     this.thresholdTextStyle,
//   });

//   static const markerSize = 24.0;
//   static const arrowSize = 24.0;

//   @override
//   Widget build(BuildContext context) {
//     assert(thresholds.isNotEmpty, 'thresholds cannot be empty');

//     // sort an toàn (không mutate original)
//     final sortedThresholds = List<double>.from(thresholds)..sort();

//     final textStyle = thresholdTextStyle ?? R.style.smallBodyStyle.neutral4;

//     return LayoutBuilder(builder: (context, constraints) {
//       final totalWidth =
//           (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
//               ? constraints.maxWidth
//               : 300.0;

//       final sections = sortedThresholds.length + 1;
//       final segmentWidth =
//           (totalWidth - gap * (sections - 1)) / sections; // width mỗi ô

//       // chuẩn màu (bù gray nếu thiếu)
//       final segColors = List<Color>.generate(sections,
//           (i) => (i < colors.length ? colors[i] : Colors.grey.shade300));

//       // tính vị trí marker theo logic: nếu = mốc -> đúng mốc; nếu giữa -> giữa ô
//       double computeMarkerX() {
//         const eps = 1e-9;
//         // trường hợp nhỏ hơn mốc đầu -> ô 0
//         if (currentValue < sortedThresholds.first - eps) {
//           return 0 * (segmentWidth + gap) + segmentWidth / 2;
//         }

//         // check bằng mốc
//         for (int i = 0; i < sortedThresholds.length; i++) {
//           if ((currentValue - sortedThresholds[i]).abs() < eps) {
//             // boundary giữa section i và i+1: startX of section (i+1)
//             return (i + 1) * (segmentWidth + gap);
//           }
//         }

//         // nằm giữa các mốc
//         for (int i = 0; i < sortedThresholds.length; i++) {
//           if (currentValue < sortedThresholds[i]) {
//             // thuộc section i
//             final startX = i * (segmentWidth + gap);
//             return startX + segmentWidth / 2;
//           }
//         }

//         // nếu lớn hơn mốc cuối -> ô cuối
//         return (sections - 1) * (segmentWidth + gap) + segmentWidth / 2;
//       }

//       final markerCenterX = computeMarkerX();
//       // clamp to viewable region so marker không ra ngoài
//       final markerLeft =
//           (markerCenterX - markerSize / 2).clamp(0.0, totalWidth - markerSize);

//       // vị trí các label (mỗi label đặt ngay tại boundary giữa ô i và i+1)
//       final labelTop = 4.0; // khoảng cách từ top stack đến label
//       final labels = <Positioned>[];
//       for (int i = 0; i < sortedThresholds.length; i++) {
//         final boundaryX = (i + 1) * (segmentWidth + gap);
//         final labelBoxWidth = segmentWidth; // width box để center label
//         final left = (boundaryX - labelBoxWidth / 2)
//             .clamp(0.0, totalWidth - labelBoxWidth);
//         labels.add(Positioned(
//           left: left,
//           top: labelTop,
//           width: labelBoxWidth,
//           child: Center(
//             child: Text(
//               // format đẹp hơn nếu cần
//               _formatThreshold(sortedThresholds[i]),
//               style: textStyle,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ));
//       }

//       // build segment widgets (bo góc chỉ cho đầu & cuối)
//       final segments = <Widget>[];
//       for (int i = 0; i < sections; i++) {
//         final radius = BorderRadius.all(Radius.circular(borderRadius));

//         segments.add(Container(
//           width: segmentWidth,
//           height: barHeight,
//           decoration: BoxDecoration(
//             color: segColors[i],
//             borderRadius: radius,
//           ),
//         ));

//         // gap giữa các ô (ngoại trừ ô cuối)
//         if (i < sections - 1) {
//           segments.add(SizedBox(width: gap));
//         }
//       }

//       // tổng chiều cao: top marker + khoảng label + labelHeight + spacing + barHeight
//       final labelHeight = (textStyle.fontSize ?? 12) + 4;
//       final topSpacing = 2.0;
//       final markerTop = 0.0;

//       final barsTop = markerSize + 4.0;
//       final labelsTop =
//           arrowSize + topSpacing + barsTop - (textStyle.fontSize ?? 12);

//       return SizedBox(
//         height: markerSize + topSpacing + labelHeight + 6 + barHeight,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // 1) marker (topmost)
//             Positioned(
//               left: markerLeft,
//               top: markerTop,
//               width: markerSize,
//               height: markerSize,
//               child: Column(
//                 children: [
//                   // Text.rich(
//                   //   TextSpan(
//                   //       text: "BMI ",
//                   //       style: R.style.normalTextStyle.neutral4,
//                   //       children: [
//                   //         TextSpan(
//                   //           text: "$currentValue",
//                   //           style: R.style.boldNormalStyle.mainColor,
//                   //         )
//                   //       ]),
//                   // ),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.arrow_drop_down,
//                         size: arrowSize,
//                         color: Colors.black,
//                       ),
//                       Text("BMI", style: R.style.boldSmallStyle)
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // 2) labels (mốc) - aligned under marker
//             // add each threshold label
//             ...labels.map((w) => Positioned(
//                   left: w.left,
//                   top: labelsTop,
//                   child: SizedBox(
//                     width: w.width,
//                     child: (w.child as Center).child,
//                   ),
//                 )),

//             // 3) colored bar (below labels)
//             Positioned(
//               left: 0,
//               top: barsTop,
//               right: 0,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(50),
//                 child: SizedBox(
//                   height: barHeight,
//                   width: double.maxFinite,
//                   child: Row(
//                       children: colors
//                           .map((color) =>
//                               Expanded(child: Container(color: color)))
//                           .toList()),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   String _formatThreshold(double v) {
//     // format: nếu là integer -> no decimal, else keep 1 or 2 decimals
//     if (v % 1 == 0) return v.toInt().toString();
//     if ((v * 10) % 1 == 0) return v.toStringAsFixed(1);
//     return v.toString();
//   }
// }


import 'package:flutter/material.dart';

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
              child: markerWidget ??
                  Icon(Icons.arrow_drop_down, size: arrowSize, color: Colors.black),
            ),
            // labels
            ...labels,
            
            // bar
            Positioned(
              top: markerSize + 20,
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

