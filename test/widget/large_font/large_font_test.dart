import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/utils/app_text_scale.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_functions.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/calendar_navigation_bar.dart';

import '../../helpers/localized_app.dart';

/// Android's largest font setting (Pixel: 2.0).
const _maxSystemFont = TextScaler.linear(2.0);

/// Small phone at the largest display size, in logical pixels.
const _smallScreen = Size(320, 560);

Future<void> _useSmallScreen(WidgetTester tester) async {
  tester.view.physicalSize = _smallScreen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Mirrors `App`'s MaterialApp.builder: system font 2.0, capped by the app.
Widget _largeFontBuilder(BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: appTextScaler(_maxSystemFont)),
      child: child!,
    );

void main() {
  setUpAll(initTestLocalization);

  group('appTextScaler', () {
    test('caps the largest system font at kMaxAppTextScale', () {
      expect(appTextScaler(_maxSystemFont).scale(10), 10 * kMaxAppTextScale);
    });

    test('leaves default and smaller settings alone', () {
      expect(appTextScaler(TextScaler.noScaling).scale(10), 10);
      expect(appTextScaler(const TextScaler.linear(0.85)).scale(10), 8.5);
    });
  });

  testWidgets(
      'BP input-method sheet: "Nhập thủ công" reachable at the largest font',
      (tester) async {
    await _useSmallScreen(tester);
    await pumpLocalized(
      tester,
      builder: _largeFontBuilder,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => BloodPressureFunctions.showModalAddData(context),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Used to be clipped by the sheet's fixed 365px height (overflow error
    // and an untappable option); now the options scroll.
    final manual = find.text('Nhập thủ công');
    await tester.ensureVisible(manual);
    await tester.pumpAndSettle();
    expect(manual.hitTestable(), findsOneWidget);
  });

  group('CalendarNavigationBar (Program > Hoạt động)', () {
    Future<double> dateTextHeight(WidgetTester tester, TextScaler scaler,
        {required Size screen}) async {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpLocalized(
        tester,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: appTextScaler(scaler)),
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CalendarNavigationBar(
              currentDate: DateTime(2026, 11, 18),
              onPreviousDay: () {},
              onNextDay: () {},
              onTodayPressed: () {},
              onDatePicked: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      return tester.getSize(find.textContaining('18/11')).height;
    }

    testWidgets('one line at default size', (tester) async {
      await dateTextHeight(tester, TextScaler.noScaling,
          screen: const Size(375, 812));
      final today = tester.getCenter(find.text('Hôm nay'));
      final date = tester.getCenter(find.textContaining('18/11'));
      expect((today.dy - date.dy).abs(), lessThan(1));
    });

    testWidgets('date stays readable at the largest font', (tester) async {
      final height =
          await dateTextHeight(tester, _maxSystemFont, screen: _smallScreen);
      // Squeezed into one line it scaled down to a few pixels; on its own
      // line it keeps (at least) its normal 15px size.
      expect(height, greaterThanOrEqualTo(15));
      final today = tester.getCenter(find.text('Hôm nay'));
      final date = tester.getCenter(find.textContaining('18/11'));
      expect(today.dy, greaterThan(date.dy));
    });
  });

  testWidgets('ButtonWidget label fits a fixed-width button at large font',
      (tester) async {
    await _useSmallScreen(tester);
    await pumpLocalized(
      tester,
      builder: _largeFontBuilder,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 195, // introduce_survey_page's "Bắt đầu khảo sát" button
            child: ButtonWidget(title: 'Bắt đầu khảo sát', onPressed: () {}),
          ),
        ),
      ),
    );

    // An overflowing Row would have thrown a layout error here.
    expect(tester.takeException(), isNull);
    final label = tester.getRect(find.text('Bắt đầu khảo sát'));
    final button = tester.getRect(find.byType(ButtonWidget));
    expect(button.contains(label.topLeft) && button.contains(label.bottomRight),
        isTrue);
  });
}
