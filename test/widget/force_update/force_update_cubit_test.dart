import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/force_update/force_update_cubit.dart';

/// Scriptable dependencies for [ForceUpdateCubit] (it takes plain functions,
/// so no mocking library is needed).
class _Deps {
  String? current = '2.5.1';
  String? required = '2.6.0';
  Object? requiredThrows;
  int currentCalls = 0;
  int requiredCalls = 0;
  int refreshCalls = 0;
  final List<String> callOrder = [];

  /// When set, currentVersion() waits on this before returning.
  Completer<void>? gateCurrent;

  ForceUpdateCubit build({
    Future<void> Function()? waitUntilReady,
    bool withRefresh = true,
  }) {
    return ForceUpdateCubit(
      currentVersion: () async {
        currentCalls++;
        callOrder.add('current');
        if (gateCurrent != null) await gateCurrent!.future;
        return current;
      },
      requiredVersion: () {
        requiredCalls++;
        callOrder.add('required');
        if (requiredThrows != null) throw requiredThrows!;
        return required;
      },
      waitUntilReady: waitUntilReady,
      refreshRemote: withRefresh
          ? () async {
              refreshCalls++;
              callOrder.add('refresh');
            }
          : null,
    );
  }
}

/// Collects every state emitted by [cubit] while [body] runs.
Future<List<ForceUpdateState>> _record(
    ForceUpdateCubit cubit, Future<void> Function() body) async {
  final states = <ForceUpdateState>[];
  final sub = cubit.stream.listen(states.add);
  await body();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

/// The cubit reports swallowed errors via `TrackingManager.recordError`, which
/// calls `FirebaseCrashlytics.instance` (no Firebase app in unit tests) and
/// fails asynchronously, unawaited. Run [body] in a guarded zone so that
/// plugin failure doesn't fail the test; callers assert on the captured list.
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
  group('ForceUpdateCubit.start()', () {
    test('required > current => ForceUpdateRequired(trimmed required version)',
        () async {
      final deps = _Deps()..required = ' 2.6.0 ';
      final cubit = deps.build();
      final states = await _record(cubit, cubit.start);
      expect(states, [
        isA<ForceUpdateRequired>()
            .having((s) => s.requiredVersion, 'requiredVersion', '2.6.0'),
      ]);
      await cubit.close();
    });

    test('required == current => ForceUpdateNotRequired', () async {
      final deps = _Deps()..required = '2.5.1';
      final cubit = deps.build();
      final states = await _record(cubit, cubit.start);
      expect(states, [isA<ForceUpdateNotRequired>()]);
      await cubit.close();
    });

    test('empty Remote Config value => ForceUpdateNotRequired', () async {
      final deps = _Deps()..required = '';
      final cubit = deps.build();
      final states = await _record(cubit, cubit.start);
      expect(states, [isA<ForceUpdateNotRequired>()]);
      await cubit.close();
    });

    test('waits for waitUntilReady before the first check', () async {
      final ready = Completer<void>();
      final deps = _Deps();
      final cubit = deps.build(waitUntilReady: () => ready.future);
      final startFuture = cubit.start();
      await Future<void>.delayed(Duration.zero);
      expect(deps.currentCalls, 0);
      expect(cubit.state, isA<ForceUpdateInitial>());
      ready.complete();
      await startFuture;
      expect(cubit.state, isA<ForceUpdateRequired>());
      await cubit.close();
    });

    test('waitUntilReady throwing still runs the check (never blocks)',
        () async {
      final deps = _Deps();
      final cubit = deps.build(
          waitUntilReady: () async => throw StateError('rc init failed'));
      final zoneErrors = await _guarded(cubit.start);
      expect(cubit.state, isA<ForceUpdateRequired>());
      expect(zoneErrors.whereType<StateError>(), isEmpty,
          reason: 'the cubit must catch the waitUntilReady error itself');
      await cubit.close();
    });
  });

  group('ForceUpdateCubit.check()', () {
    test('before start() => ignored, no emission, no fetch', () async {
      final deps = _Deps();
      final cubit = deps.build();
      final states = await _record(cubit, () => cubit.check(refresh: true));
      expect(states, isEmpty);
      expect(deps.currentCalls, 0);
      expect(deps.refreshCalls, 0);
      expect(cubit.state, isA<ForceUpdateInitial>());
      await cubit.close();
    });

    test('concurrent check() calls => only one fetch in flight', () async {
      final deps = _Deps()..required = '2.5.1';
      final cubit = deps.build();
      await cubit.start(); // 1 fetch
      expect(deps.currentCalls, 1);

      deps.gateCurrent = Completer<void>();
      final first = cubit.check();
      final second = cubit.check();
      final third = cubit.check(refresh: true);
      await Future<void>.delayed(Duration.zero);
      deps.gateCurrent!.complete();
      await Future.wait([first, second, third]);

      expect(deps.currentCalls, 2,
          reason: 'only the first of the concurrent calls runs');
      expect(deps.refreshCalls, 0,
          reason: 'the ignored refresh call must not hit Remote Config');

      // In-flight flag is released afterwards.
      deps.gateCurrent = null;
      await cubit.check();
      expect(deps.currentCalls, 3);
      await cubit.close();
    });

    test('check(refresh: true) calls refreshRemote before reading versions',
        () async {
      final deps = _Deps();
      final cubit = deps.build();
      await cubit.start();
      deps.callOrder.clear();
      await cubit.check(refresh: true);
      expect(deps.refreshCalls, 1);
      expect(deps.callOrder, ['refresh', 'current', 'required']);
      await cubit.close();
    });

    test('check() without refresh does not call refreshRemote', () async {
      final deps = _Deps();
      final cubit = deps.build();
      await cubit.start();
      await cubit.check();
      expect(deps.refreshCalls, 0);
      await cubit.close();
    });

    test('Required -> NotRequired once Remote Config lowers the minimum',
        () async {
      final deps = _Deps()..required = '2.6.0';
      final cubit = deps.build();
      final states = await _record(cubit, () async {
        await cubit.start();
        deps.required = '2.5.0';
        await cubit.check(refresh: true);
      });
      expect(states,
          [isA<ForceUpdateRequired>(), isA<ForceUpdateNotRequired>()]);
      await cubit.close();
    });

    test('check() after close() is a no-op', () async {
      final deps = _Deps();
      final cubit = deps.build();
      await cubit.start();
      await cubit.close();
      final before = deps.currentCalls;
      await cubit.check();
      expect(deps.currentCalls, before);
    });

    test(
        'requiredVersion throwing => state unchanged, error swallowed, '
        'later checks still run', () async {
      final deps = _Deps()..required = '2.5.1';
      final cubit = deps.build();
      await cubit.start();
      expect(cubit.state, isA<ForceUpdateNotRequired>());

      deps.requiredThrows = StateError('remote config exploded');
      final states = <ForceUpdateState>[];
      final sub = cubit.stream.listen(states.add);
      final zoneErrors = await _guarded(cubit.check);
      await sub.cancel();

      expect(states, isEmpty);
      expect(cubit.state, isA<ForceUpdateNotRequired>());
      expect(zoneErrors.whereType<StateError>(), isEmpty,
          reason: 'the cubit must catch the requiredVersion error itself');

      // _checking was reset in `finally`: a later check works.
      deps.requiredThrows = null;
      deps.required = '3.0.0';
      await cubit.check();
      expect(cubit.state, isA<ForceUpdateRequired>());
      await cubit.close();
    });
  });
}
