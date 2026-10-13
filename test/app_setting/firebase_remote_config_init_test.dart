@Tags(['regression'])
library;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
// Transitive dependencies (not listed in pubspec dev_dependencies); used only
// for the official Firebase test mocks.
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FirebaseRemoteSetting.init() (lib/src/app_setting/firebase_remote_config.dart):
// a corrupt locally-saved settings JSON used to make `jsonDecode` throw at the
// top of init(), so `initialized` never completed and ForceUpdateCubit.start()
// (which awaits it) never ran its first check — the force update was silently
// disabled. Fix: decode wrapped in try/catch.

/// Offline Remote Config: setDefaults is honoured, fetch always fails, so
/// every getter returns the default that init() derived from local settings.
class _OfflineRemoteConfig extends FirebaseRemoteConfigPlatform
    with MockPlatformInterfaceMixin {
  _OfflineRemoteConfig() : super();

  Map<String, dynamic> defaults = {};

  @override
  FirebaseRemoteConfigPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseRemoteConfigPlatform setInitialValues(
          {required Map<dynamic, dynamic> remoteConfigValues}) =>
      this;

  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) async {
    defaults = Map.of(defaultParameters);
  }

  @override
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) async {}

  @override
  Future<bool> fetchAndActivate() async =>
      throw FirebaseException(plugin: 'remote_config', message: 'offline');

  @override
  String getString(String key) => defaults[key]?.toString() ?? '';

  @override
  bool getBool(String key) => defaults[key] == true;
}

const _localKey = 'firebaseRemoteSettings'; // AppSettings.getFirebaseRemoteSettings

/// TrackingManager.recordError -> FirebaseCrashlytics has no platform
/// implementation here and fails asynchronously (unawaited); capture it.
Future<List<Object>> _guarded(Future<void> Function() body) async {
  final errors = <Object>[];
  final done = Completer<void>();
  runZonedGuarded(() async {
    await body();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    done.complete();
  }, (e, _) => errors.add(e));
  await done.future;
  return errors;
}

void main() {
  late _OfflineRemoteConfig remote;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    remote = _OfflineRemoteConfig();
    FirebaseRemoteConfigPlatform.instance = remote;
    SharedPreferences.setMockInitialValues({});
    await AppPreference.ensureInitialized();
  });

  // FirebaseRemoteSetting is a process-wide singleton whose `initialized`
  // completer completes only once, so the completion assertion must run in
  // the first test that calls init().
  group('FirebaseRemoteSetting.init() with a corrupt local settings copy', () {
    test('does not throw, completes `initialized`, falls back to defaults',
        () async {
      await appPreference.setData(_localKey, '{"PLAY_STORE_VERSION": "2.6');
      var initialized = false;
      unawaited(FirebaseRemoteSetting.instance.initialized
          .then((_) => initialized = true));

      Object? thrown;
      final zoneErrors = await _guarded(() async {
        try {
          await FirebaseRemoteSetting.instance
              .init(timeout: const Duration(seconds: 1));
        } catch (e) {
          thrown = e;
        }
      });

      expect(thrown, isNull);
      expect(zoneErrors.whereType<FormatException>(), isEmpty);
      expect(initialized, isTrue,
          reason: 'ForceUpdateCubit.start() awaits this future');
      // Hardcoded fallbacks in init()'s setDefaults.
      expect(FirebaseRemoteSetting.instance.playStoreVersion, '1.4.5');
      expect(FirebaseRemoteSetting.instance.appStoreVersion, '1.4.3');
    });

    test('valid local copy => its store versions are used offline', () async {
      await appPreference.setData(_localKey,
          '{"PLAY_STORE_VERSION": "2.6.0", "APP_STORE_VERSION": "2.6.1"}');
      await _guarded(() =>
          FirebaseRemoteSetting.instance.init(timeout: const Duration(seconds: 1)));
      expect(FirebaseRemoteSetting.instance.playStoreVersion, '2.6.0');
      expect(FirebaseRemoteSetting.instance.appStoreVersion, '2.6.1');
    });
  });
}
