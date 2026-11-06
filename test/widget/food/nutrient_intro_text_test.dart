import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';

import '../../helpers/localized_app.dart';

// Nutrition intro "Bạn có biết?" used the blood-pressure sentence
// (bloodpressure_benefit_observe); it now reads nutrient_benefit_record
// (lib/src/widget/Food/intro/nutrient_intro_1st_page.dart:156).
// The page itself builds FoodClient() in initState, so it isn't pumped here;
// this checks the key resolves through the real CSV loader in both locales.

void main() {
  setUpAll(initTestLocalization);

  Future<String> resolve(WidgetTester tester, Locale locale) async {
    late String text;
    await pumpLocalized(tester,
        locale: locale,
        home: Builder(builder: (context) {
          text = R.string.nutrient_benefit_record.tr();
          return Text(text);
        }));
    return text;
  }

  testWidgets('vi text', (tester) async {
    expect(
        await resolve(tester, const Locale('vi')),
        'Ghi lại bữa ăn mỗi ngày giúp bạn nắm rõ thói quen ăn uống và '
        'xây dựng chế độ dinh dưỡng lành mạnh hơn.');
  });

  testWidgets('en text', (tester) async {
    expect(
        await resolve(tester, const Locale('en')),
        'Logging your meals every day helps you understand your eating '
        'habits and build a healthier diet.');
  });

  testWidgets('differs from the blood-pressure sentence', (tester) async {
    late String bp;
    late String food;
    await pumpLocalized(tester, home: Builder(builder: (context) {
      bp = R.string.bloodpressure_benefit_observe.tr();
      food = R.string.nutrient_benefit_record.tr();
      return const SizedBox();
    }));
    expect(food, isNot(bp));
  });
}
