import 'dart:convert';
import 'dart:developer' as developer;

class Console {
  static const String TAG = "SS Managers";

  static log([String tag = TAG, dynamic msg]) {
    developer.log('$msg', name: tag);
  }

  static logJson([String tag = TAG, dynamic msg]) {
    final prettyString = const JsonEncoder.withIndent('  ').convert(msg);
    developer.log(prettyString, name: tag);
  }

  ///Singleton factory
  static final Console _instance = Console._internal();

  factory Console() {
    return _instance;
  }

  Console._internal();
}
