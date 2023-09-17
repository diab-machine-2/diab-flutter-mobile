import 'dart:convert';
import 'dart:developer' as developer;

import 'package:medical/src/utils/const.dart';

class Console {
  static const String TAG = "diaB";

  static log([String tag = TAG, dynamic msg]) {
    if (Const.ENVIRONMENT_DEFAULT == 'staging') {
      developer.log('$msg', name: tag);
    }
  }

  static logJson([String tag = TAG, dynamic msg]) {
    if (Const.ENVIRONMENT_DEFAULT == 'staging') {
      final prettyString = const JsonEncoder.withIndent('  ').convert(msg);
      developer.log(prettyString, name: tag);
    }
  }

  ///Singleton factory
  static final Console _instance = Console._internal();

  factory Console() {
    return _instance;
  }

  Console._internal();
}
