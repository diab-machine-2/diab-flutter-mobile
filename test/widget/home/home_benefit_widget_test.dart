import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
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

        // QA: a one-line title must not sit lower than the two-line one
        // in the other card.
        final clinicTitle = hasRecord
            ? R.string.home_benefit_book_clinic.tr()
            : R.string.kham_tai_phong_kham.tr();
        expect(tester.getTopLeft(find.text(clinicTitle)).dy,
            tester.getTopLeft(find.text(R.string.kham_tu_xa.tr())).dy);
      });
    }
  }
}
