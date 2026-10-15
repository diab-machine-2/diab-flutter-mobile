import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/shimmer_box.dart';
import 'package:medical/src/widgets/specialty_grid.dart';
import 'package:medical/src/widgets/specialty_select_view.dart';

import '../../helpers/localized_app.dart';

void main() {
  setUpAll(initTestLocalization);

  Future<void> pumpView(
    WidgetTester tester, {
    required SpecialtySelectStatus status,
    List<SpecialtyGridItem> items = const [],
    List<Widget>? actions,
    VoidCallback? onRetry,
  }) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(
      tester,
      home: Scaffold(
        body: SpecialtySelectView(
          status: status,
          items: items,
          actions: actions,
          onRetry: onRetry,
          onBack: () {},
        ),
      ),
    );
  }

  testWidgets('header uses the Figma title', (tester) async {
    await pumpView(tester, status: SpecialtySelectStatus.ready);
    expect(find.text('Chọn nhu cầu khám'), findsOneWidget);
  });

  testWidgets('loading → skeleton', (tester) async {
    await pumpView(tester, status: SpecialtySelectStatus.loading);
    expect(find.byType(ShimmerBox), findsWidgets);
    expect(find.byType(SpecialtyGrid), findsNothing);
  });

  testWidgets('ready with no items → empty message, no retry', (tester) async {
    await pumpView(tester, status: SpecialtySelectStatus.ready);
    expect(find.text('Chưa có nơi khám phù hợp yêu cầu'), findsOneWidget);
    expect(find.text('Thử lại'), findsNothing);
  });

  testWidgets('error → message and retry', (tester) async {
    var retries = 0;
    await pumpView(tester,
        status: SpecialtySelectStatus.error, onRetry: () => retries++);
    await tester.tap(find.text('Thử lại'));
    expect(retries, 1);
  });

  testWidgets('ready → grid; tapping an item calls its onTap', (tester) async {
    String? tapped;
    await pumpView(
      tester,
      status: SpecialtySelectStatus.ready,
      items: [
        for (final name in [
          'Tim mạch',
          'Tăng huyết áp',
          'Thận mạn tính',
          'Tinh thần'
        ])
          SpecialtyGridItem(
            name: name,
            assetIcon: R.drawable.ic3d_tim_mach,
            onTap: () => tapped = name,
          ),
      ],
    );
    expect(find.byType(SpecialtyGrid), findsOneWidget);
    await tester.tap(find.text('Tinh thần'));
    expect(tapped, 'Tinh thần');
    expect(tester.takeException(), isNull);
  });

  testWidgets('history button only when passed', (tester) async {
    await pumpView(tester, status: SpecialtySelectStatus.ready);
    expect(find.byType(SpecialtyHistoryButton), findsNothing);

    var opened = 0;
    await pumpView(tester,
        status: SpecialtySelectStatus.ready,
        actions: [SpecialtyHistoryButton(onTap: () => opened++)]);
    await tester.tap(find.text('Lịch hẹn'));
    expect(opened, 1);
  });
}
