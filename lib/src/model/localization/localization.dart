import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';

import 'csv_loader/csv_asset_loader.dart';

class Localization {
  static const List<Locale> supportedLanguage = [Locale(Const.EN), Locale(Const.VI)];
  static const Locale defaultLanguage = Locale(Const.VI);
  static const String languageFilePath = 'lib/res/translations/langs.csv';

  static Widget getLocalizationWidget({required app}) {
    return EasyLocalization(
          supportedLocales: supportedLanguage,
          path: languageFilePath,
          fallbackLocale: defaultLanguage,
          startLocale: Locale(AppPreference().appLanguage),
          assetLoader: CsvAssetLoader(),
          child: app
    );
  }

  static changeLanguage(BuildContext context, String newLanguageCode) {
    if (newLanguageCode == Const.EN) {
      context.locale = Localization.supportedLanguage[0];
      appPreference.saveAppLanguage(Localization.supportedLanguage[0].languageCode);
    } else {
      context.locale = Localization.supportedLanguage[1];
      appPreference.saveAppLanguage(Localization.supportedLanguage[1].languageCode);
    }
  }
}
