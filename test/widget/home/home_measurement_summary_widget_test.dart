import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/home_view_flags.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/home/widget/home_measurement_summary.dart';

import '../../helpers/localized_app.dart';

void main() {
  setUpAll(initTestLocalization);

  MeasurementSummary card() => MeasurementSummary(
        inlineMeasurements: [
          HomeMeasurementInlineData(
              title: 'HbA1C',
              value: '6.5',
              unit: '%',
              color: 0xff0E7B6B,
              titleColor: 0xff111515),
          HomeMeasurementInlineData(
              icon: 'weight',
              value: '152,9',
              unit: 'Kg',
              color: 0xff0E7B6B,
              titleColor: 0xff111515),
          HomeMeasurementInlineData(
              title: 'BMI',
              value: '22,3',
              unit: 'Kg/m²',
              color: 0xff0E7B6B,
              titleColor: 0xff111515),
        ],
        measurements: [
          for (final title in [
            'Đường huyết',
            'Huyết áp',
            'Vận động',
            'Dinh dưỡng'
          ])
            HomeMeasurementData(
              title: title,
              titleColor: 0xff111515,
              icon: R.drawable.ic3d_chung,
              value1: '120',
              value1Color: 0xff0E7B6B,
              unit: 'mmHg',
            ),
        ],
        flags: const HomeViewFlags(hasKpi: true, hasRecord: true),
        onAddMeasurement: () {},
        onConnectDevice: () {},
        onHealthProfile: () {},
        onMeasurement: (_, __, ___) {},
      );

  // 320dp ≈ a small phone with "Display size" at its largest.
  for (final width in const [320.0, 360.0]) {
    for (final scale in const [1.0, 1.3, 2.0]) {
      testWidgets('KPI card fits ${width}dp at text scale $scale',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpLocalized(
          tester,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: card(),
              ),
            ),
          ),
        );

        // RenderFlex overflow would surface here.
        expect(tester.takeException(), isNull);
      });
    }
  }
}
