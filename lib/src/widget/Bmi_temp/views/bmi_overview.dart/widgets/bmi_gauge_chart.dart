import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/Bmi/bmi_utils.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_state.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BmiGaugeChart extends StatelessWidget {
  const BmiGaugeChart({super.key});

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();
    Color thresholdColor =
        BmiUtils.getAvgBmiThresholdColor(_bmiInputBloc.bmi);
    double minValue = Const.bmiThreshold.first - 2.5;
    double maxValue = Const.bmiThreshold.last + 2.5;

    return BlocBuilder<BmiInputBloc, BmiInputState>(builder: (context, state) {
      return Padding(
        // width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: minValue,
              maximum: maxValue,
              startAngle: 160,
              endAngle: 20,
              // showLabels: true,
              showFirstLabel: false,
              labelOffset: -20,
              tickOffset: -50,
              showTicks: true,
              radiusFactor: 0.8,
              canScaleToFit: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.3,
                thicknessUnit: GaugeSizeUnit.factor,
                color: AppColors.neutral5,
                cornerStyle: CornerStyle.bothCurve,
              ),
              ranges: buildGaugeRangesWithHighlight(
                thresholds: Const.bmiThreshold,
                colors: [],
                current: _bmiInputBloc.bmi,
                highlightColor: thresholdColor,
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: _bmiInputBloc.bmi, // BMI hiện tại
                  needleColor: AppColors.neutral4,
                  needleStartWidth: 1,
                  needleEndWidth: 4,
                  needleLength: 0.3,
                  knobStyle: const KnobStyle(color: AppColors.neutral4),
                  enableAnimation: true,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.5,
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Thừa cân',
                        style: R.style.smallDisplayStyle
                            .copyWith(color: thresholdColor),
                      ),
                      SizedBox(height: 8),
                      Text.rich(TextSpan(
                          text: "${_bmiInputBloc.weight} ",
                          style: R.style.boldXLargeStyle,
                          children: [
                            TextSpan(
                              text: "kg",
                              style: R.style.normalTextStyle.neutral3,
                            )
                          ]))
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  List<GaugeRange> buildGaugeRangesWithHighlight({
    required List<double> thresholds,
    required List<Color> colors,
    required double current,
    double startWidth = 40,
    double endWidth = 40,
    Color defaultColor = AppColors.neutral5,
    double highlightOpacity = 1.0, // 1.0 = giữ nguyên, <1.0 = làm mờ
    Color? highlightColor, // nếu muốn truyền màu highlight riêng
  }) {
    // thresholds phải >= 2
    if (thresholds.length < 2) {
      throw ArgumentError('Cần ít nhất 2 mốc để tạo range');
    }

    final sortedThresholds = List<double>.from(thresholds)..sort();
    final List<GaugeRange> ranges = [];

    for (int i = 0; i < sortedThresholds.length - 1; i++) {
      final double start = sortedThresholds[i];
      final double end = sortedThresholds[i + 1];
      final bool isInThisRange =
          current >= start && current < end; // highlight range chứa current

      Color baseColor = i < colors.length ? colors[i] : defaultColor;
      Color finalColor = isInThisRange
          ? (highlightColor ??
              baseColor) // nếu truyền highlightColor thì dùng nó
          : baseColor
              .withOpacity(highlightOpacity); // range khác thì giảm opacity

      ranges.add(
        GaugeRange(
          startValue: start,
          endValue: end,
          color: finalColor,
          startWidth: startWidth,
          endWidth: endWidth,
        ),
      );
    }

    return ranges;
  }
}
