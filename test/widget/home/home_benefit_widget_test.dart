import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/home/widget/home_benefit.dart';

import '../../helpers/localized_app.dart';

void main() {
  setUpAll(initTestLocalization);

  for (final locale in const [Locale('vi'), Locale('en')]) {
    for (final hasRecord in const [false, true]) {
      testWidgets(
          'benefit section fits 360dp at text scale 1.3 '
          '(${locale.languageCode}, hasRecord: $hasRecord)', (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpLocalized(
          tester,
          locale: locale,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: HomeBenefitSection(
                    hasRecord: hasRecord, shortcutsConfig: ''),
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
