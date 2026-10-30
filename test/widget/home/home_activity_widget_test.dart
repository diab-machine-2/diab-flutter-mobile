import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/home/widget/home_activity.dart';

import '../../helpers/localized_app.dart';

void main() {
  setUpAll(initTestLocalization);

  final reminders = [
    for (var i = 0; i < 3; i++)
      HomeReminderData(icon: '', title: 'aa', time: '11:00 đêm'),
  ];

  Future<void> pump(WidgetTester tester, {required bool expanded}) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(
      tester,
      locale: const Locale('vi'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: HomeActivity(
            activities: const [],
            reminders: reminders,
            hasProgram: false,
            expanded: expanded,
            onToggleExpanded: () {},
            onViewProgram: () {},
            onAddActivity: () {},
            onActivityTap: (_) {},
            onReminderTap: (_) {},
          ),
        ),
      ),
    );
  }

  for (final expanded in const [false, true]) {
    testWidgets('label stays "Xem tất cả", chevron turns (expanded: $expanded)',
        (tester) async {
      await pump(tester, expanded: expanded);
      expect(find.text(R.string.view_all.tr()), findsOneWidget);
      expect(find.text(R.string.show_less.tr()), findsNothing);
      final rotation =
          tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(rotation.turns, expanded ? 0.25 : 0);
    });
  }

  testWidgets('reminder time is pinned to the right edge of its card',
      (tester) async {
    await pump(tester, expanded: false);
    final time = find.text('11:00 đêm').first;
    final card = find.ancestor(of: time, matching: find.byType(Material)).first;
    // Card padding is 12; the time used to float mid-card.
    expect(tester.getTopRight(card).dx - tester.getTopRight(time).dx,
        lessThanOrEqualTo(12.5));
  });
}
