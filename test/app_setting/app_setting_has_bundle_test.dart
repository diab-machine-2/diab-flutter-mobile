@Tags(['regression'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_user.dart';

// Issue 1: a bundle deleted server-side kept being resurrected from the stale
// on-disk `home_data` cache ({"hasBundle": true}), flip-flopping
// AppSettings.hasBundle true/false; every flip fires UPDATE_HAS_BUNDLE, which
// TabbarController (lib/src/widget/tabbar/tabbar_v2.dart:403) answers with a
// rebuild that calls checkHasBundle() again -> endless rebuild loop.
// Fix: lib/src/app_setting/app_setting.dart `_hasBundleFromServer`,
// setHasBundleFromServer / setHasBundleFromCache / checkHasBundle /
// deleteHomeData / logout.

const _homeKey = 'home_data';

/// Counts UPDATE_HAS_BUNDLE notifications — the signal TabbarController
/// rebuilds on.
class _HasBundleCounter with Observer {
  int count = 0;

  @override
  update(Observable observable, String? notifyName, Map? map) {
    if (notifyName == Const.UPDATE_HAS_BUNDLE) count++;
  }
}

/// Minimal cached /App/Home payload that HomeModel.fromJson accepts.
Map<String, dynamic> _homeJson({required bool hasBundle}) => {
      'glucoseIndex': <String, dynamic>{},
      'bloodPressureIndex': <String, dynamic>{},
      'hbA1CIndex': <String, dynamic>{},
      'hasBundle': hasBundle,
    };

Future<void> _writeCache(Map<String, dynamic> json) =>
    appPreference.setData(_homeKey, jsonEncode(json));

Map<String, dynamic>? _readCache() {
  final raw = appPreference.getData(_homeKey);
  return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  late _HasBundleCounter counter;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreference.ensureInitialized();
    // GloucoseIndexModel.fromJson (used by getHome) dereferences userInfo.
    AppSettings.userInfo = buildTestUser();
  });

  setUp(() async {
    // Reset static session state (server flag + hasBundle) and the cache.
    await AppSettings.deleteHomeData();
    counter = _HasBundleCounter();
    Observable.instance.addObserver(counter);
  });

  tearDown(() {
    Observable.instance.removeObserver(counter);
  });

  group('hasBundle source of truth (issue 1: stale cached hasBundle)', () {
    test(
        'server says false over a cached true => hasBundle false, '
        'checkHasBundle false, cache patched to false', () async {
      await _writeCache(_homeJson(hasBundle: true));
      expect(AppSettings.checkHasBundle(), isTrue,
          reason: 'precondition: cold-start first paint uses the cache');

      AppSettings.setHasBundleFromServer(false);

      expect(AppSettings.hasBundle, isFalse);
      expect(AppSettings.checkHasBundle(), isFalse);
      expect(_readCache()!['hasBundle'], isFalse,
          reason: 'next cold start must not first-paint the stale value');
    });

    test(
        'after the server answered, a later cache read (getHome / '
        'setHasBundleFromCache(true)) does not override it', () async {
      await _writeCache(_homeJson(hasBundle: true));
      AppSettings.setHasBundleFromServer(false);

      // Simulate the cache going stale again (e.g. written by an older
      // in-flight path) and HomeBloc re-reading it.
      await _writeCache(_homeJson(hasBundle: true));
      final model = await AppSettings.getHome();
      expect(model, isNotNull);
      expect(model!.hasBundle, isTrue, reason: 'precondition: cache is stale');
      expect(AppSettings.hasBundle, isFalse);

      AppSettings.setHasBundleFromCache(true);
      expect(AppSettings.hasBundle, isFalse);
      expect(AppSettings.checkHasBundle(), isFalse);
    });

    test('no server value yet => checkHasBundle falls back to cached true',
        () async {
      await _writeCache(_homeJson(hasBundle: true));
      expect(AppSettings.hasBundle, isFalse);
      expect(AppSettings.checkHasBundle(), isTrue);
      expect(AppSettings.hasBundle, isTrue);
    });

    test('no server value yet => setHasBundleFromCache applies', () async {
      AppSettings.setHasBundleFromCache(true);
      expect(AppSettings.hasBundle, isTrue);
    });

    test('server true is not downgraded by a cached false', () async {
      await _writeCache(_homeJson(hasBundle: false));
      AppSettings.setHasBundleFromServer(true);
      AppSettings.setHasBundleFromCache(false);
      expect(AppSettings.hasBundle, isTrue);
      expect(_readCache()!['hasBundle'], isTrue);
    });

    test('setHasBundleFromServer with no cache does not create one', () async {
      AppSettings.setHasBundleFromServer(true);
      expect(AppSettings.hasBundle, isTrue);
      expect(appPreference.getData(_homeKey), isNull);
    });

    test('setHasBundleFromServer tolerates a corrupt cache', () async {
      await appPreference.setData(_homeKey, '{not json');
      AppSettings.setHasBundleFromServer(false);
      expect(AppSettings.hasBundle, isFalse);
      expect(AppSettings.checkHasBundle(), isFalse);
    });

    test('saveHome(fresh response) also marks the value as server-sourced',
        () async {
      await AppSettings.saveHome(_homeJson(hasBundle: false));
      await _writeCache(_homeJson(hasBundle: true)); // stale again
      expect(AppSettings.checkHasBundle(), isFalse);
      AppSettings.setHasBundleFromCache(true);
      expect(AppSettings.hasBundle, isFalse);
    });

    test('deleteHomeData() resets the server flag and the cache', () async {
      AppSettings.setHasBundleFromServer(true);
      await AppSettings.deleteHomeData();

      expect(AppSettings.hasBundle, isFalse);
      expect(appPreference.getData(_homeKey), isNull);
      // Server flag is reset: cache reads apply again (next account).
      AppSettings.setHasBundleFromCache(true);
      expect(AppSettings.hasBundle, isTrue);
    });
  });

  group(
      'REGRESSION: UPDATE_HAS_BUNDLE rebuild loop after a bundle was deleted '
      'server-side', () {
    test(
        'after setHasBundleFromServer(false), repeated checkHasBundle() '
        '(one per TabbarController rebuild) fires no notifications', () async {
      await _writeCache(_homeJson(hasBundle: true));
      // Cold start: cached first paint (HomeBloc :86 path).
      AppSettings.setHasBundleFromCache(true);
      expect(counter.count, 1);

      // Network answers: bundle deleted (HomeBloc :124 path).
      AppSettings.setHasBundleFromServer(false);
      expect(counter.count, 2);

      // Even if the cache were stale again, rebuilds must not ping-pong.
      await _writeCache(_homeJson(hasBundle: true));
      for (var i = 0; i < 20; i++) {
        expect(AppSettings.checkHasBundle(), isFalse);
      }
      expect(counter.count, 2,
          reason: 'pre-fix, each checkHasBundle() re-read the stale cache, '
              'set hasBundle=true and notified again');
    });

    test('setting the same server value twice notifies once', () async {
      AppSettings.setHasBundleFromServer(true);
      AppSettings.setHasBundleFromServer(true);
      expect(counter.count, 1);
    });
  });

  group('logout clears the cached home before any network call', () {
    test(
        'logout whose network calls fail still removes home_data and resets '
        'hasBundle', () async {
      await _writeCache(_homeJson(hasBundle: true));
      AppSettings.setHasBundleFromServer(true);

      // In tests the network steps of logout fail on their own:
      // FetchClient.checkNetwork (DNS) and/or LoginClient.logout
      // (FirebaseMessaging.instance has no Firebase app -> throws before any
      // HTTP request). As insurance against ever reaching a real backend,
      // all HttpClient creation is also made to fail. Branch's logout is a
      // fire-and-forget platform call (MissingPluginException) — captured by
      // the guarded zone.
      final zoneErrors = <Object>[];
      final done = Completer<bool>();
      runZonedGuarded(() {
        HttpOverrides.runZoned(() async {
          final ok =
              await AppSettings.logout(isNavigateToStepListScreen: false);
          done.complete(ok);
        }, createHttpClient: (_) => throw const SocketException('blocked'));
      }, (e, _) => zoneErrors.add(e));
      final result = await done.future;

      expect(result, isFalse, reason: 'precondition: network step failed');
      expect(appPreference.getData(_homeKey), isNull);
      expect(AppSettings.hasBundle, isFalse);
      // Server flag reset: next account's cache can apply.
      AppSettings.setHasBundleFromCache(true);
      expect(AppSettings.hasBundle, isTrue);
    });
  });
}
