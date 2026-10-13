import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/localization/csv_loader/csv_asset_loader.dart';
import 'package:medical/src/model/localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Call once per test file (setUpAll) before pumping [pumpLocalized].
Future<void> initTestLocalization() async {
  SharedPreferences.setMockInitialValues({});
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
}

/// Pumps [child] inside the project's real localization setup
/// (EasyLocalization + CsvAssetLoader reading lib/res/translations/langs.csv),
/// locale `vi` unless overridden. [builder] mirrors `MaterialApp.builder`.
///
/// The CSV is loaded via rootBundle on a real async gap, so the first pump
/// happens inside `runAsync` and is followed by a settle.
Future<void> pumpLocalized(
  WidgetTester tester, {
  Widget? home,
  TransitionBuilder? builder,
  Locale locale = const Locale('vi'),
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: Localization.supportedLanguage,
        path: Localization.languageFilePath,
        fallbackLocale: Localization.defaultLanguage,
        startLocale: locale,
        saveLocale: false,
        assetLoader: CsvAssetLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            builder: builder,
            home: home ?? const SizedBox(),
          ),
        ),
      ),
    );
    // Let the CSV asset load complete on the real event loop.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pump();
}
