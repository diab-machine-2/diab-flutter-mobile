import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/bloc/bmi_input_state.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BmiGaugeChart extends StatelessWidget {
  const BmiGaugeChart({super.key});

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();

    return BlocBuilder<BmiInputBloc, BmiInputState>(
      builder: (context, state) {
        return Padding(
          // width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 15,
                maximum: 35,
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
                  color: Colors.grey.shade300,
                  cornerStyle: CornerStyle.bothCurve,
                ),
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 18.5,
                    endValue: 23,
                    color: AppColors.neutral5,
                    startWidth: 20,
                    endWidth: 20,
                  ),
                  GaugeRange(
                    startValue: 23,
                    endValue: 25,
                    color: AppColors.neutral4,
                    startWidth: 20,
                    endWidth: 20,
                  ),
                  GaugeRange(
                    startValue: 25,
                    endValue: 30,
                    color: AppColors.neutral5,
                    startWidth: 20,
                    endWidth: 20,
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: _bmiInputBloc.bmi, // BMI hiện tại
                    needleColor: AppColors.neutral4,
                    needleStartWidth: 1,
                    needleEndWidth: 4,
                    needleLength: 0.4,
                    knobStyle: const KnobStyle(color: AppColors.neutral3),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    angle: 90,
                    positionFactor: 0.5,
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Thừa cân',
                          style: R.style.smallDisplayStyle,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_bmiInputBloc.weight} kg',
                          style: R.style.boldXXLargeStyle,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      }
    );
  }
}
