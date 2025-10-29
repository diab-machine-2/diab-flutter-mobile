import 'dart:developer';
import 'dart:ui';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/utils/app_log.dart';
// import 'asset_loader.dart';
import 'package:csv/csv.dart';

//
// load example/resources/langs/langs.csv
//
class CsvAssetLoader extends AssetLoader {
  CSVParser? csvParser;

  CsvAssetLoader(); // phải có const constructor y như AssetLoader

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (csvParser == null) {
      log('easy localization loader: load csv file $path');
      csvParser = CSVParser(await rootBundle.loadString(path));
    } else {
      log('easy localization loader: CSV parser already loaded, read cache');
    }
    Map<String, dynamic> parser = Map.from({});
    try {
      parser = csvParser!.getLanguageMap(locale.toString());
    } catch (e) {
      Console.logJson('CsvAssetLoader Error', e);
    }
    return parser;
  }
}

class CSVParser {
  final String fieldDelimiter;
  final String strings;
  final List<List<dynamic>> lines;

  static final csvSettingsDetector =
      FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);

  CSVParser(this.strings, {this.fieldDelimiter = ','})
      : lines = CsvToListConverter(csvSettingsDetector: csvSettingsDetector)
            .convert(strings);

  List getLanguages() {
    return lines.first.sublist(1, lines.first.length);
  }

  Map<String, dynamic> getLanguageMap(String localeName) {
    final indexLocale = lines.first.indexOf(localeName);

    var translations = <String, dynamic>{};
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].length > indexLocale && lines[i][indexLocale] != "") {
        translations.addAll(
            {lines[i][0]: lines[i][indexLocale].replaceAll('\\n', '\n')});
      } else {
        translations.addAll({lines[i][0]: lines[i][1]});
      }
    }
    return translations;
  }
}
