import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/home/widget/header.dart';

import '../../helpers/localized_app.dart';

void main() {
  setUpAll(initTestLocalization);

  Future<String> line(WidgetTester tester, String name, Locale locale) async {
    late String result;
    await pumpLocalized(tester,
        locale: locale,
        home: Builder(builder: (_) {
          result = HomeHeader.programLine(name);
          return const SizedBox();
        }));
    return result;
  }

  testWidgets('vi: adds "Chương trình" to a bare name', (tester) async {
    expect(await line(tester, ' Health Foundation ', const Locale('vi')),
        'Chương trình Health Foundation');
  });

  testWidgets('en: "<name> program"', (tester) async {
    expect(await line(tester, 'Health Foundation', const Locale('en')),
        'Health Foundation program');
  });

  testWidgets('names that already say it are kept', (tester) async {
    expect(await line(tester, 'Chương trình HF', const Locale('vi')),
        'Chương trình HF');
    expect(await line(tester, 'Gói chương trình HF', const Locale('vi')),
        'Gói chương trình HF');
    expect(await line(tester, 'HF Program', const Locale('en')), 'HF Program');
  });
}
