import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Share of the screen a bottom sheet may take before its options scroll.
const double kSheetMaxHeightFactor = 0.9;

/// Constraints for a bottom sheet that used a fixed `height`.
///
/// At the default text size the sheet keeps its [designHeight]. With a large
/// system font / display size it grows with its content up to
/// [kSheetMaxHeightFactor] of the screen; the sheet's options must then sit
/// in a `Flexible` + `SingleChildScrollView` so they scroll instead of being
/// clipped (a fixed height hid "Nhập thủ công" in the input-method sheets).
BoxConstraints sheetConstraints(BuildContext context, double designHeight) {
  final maxHeight = MediaQuery.sizeOf(context).height * kSheetMaxHeightFactor;
  return BoxConstraints(
    minHeight: math.min(designHeight, maxHeight),
    maxHeight: maxHeight,
  );
}
