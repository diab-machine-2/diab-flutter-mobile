@Tags(['ui'])
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/force_update/force_update_cubit.dart';
import 'package:medical/src/widget/force_update/force_update_gate.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/localized_app.dart';

class _Deps {
  String? current = '2.5.1';
  String? required = '2.6.0';
  int currentCalls = 0;
  int refreshCalls = 0;

  ForceUpdateCubit build() => ForceUpdateCubit(
        currentVersion: () async {
          currentCalls++;
          return current;
        },
        requiredVersion: () => required,
        refreshRemote: () async => refreshCalls++,
      );
}

const _childButtonKey = Key('gate-child-button');
const _storeChannel = MethodChannel('store_redirect');

void main() {
  late _Deps deps;
  late ForceUpdateCubit cubit;
  late int childTaps;
  late List<MethodCall> storeCalls;

  setUpAll(initTestLocalization);

  setUp(() {
    deps = _Deps();
    cubit = deps.build();
    childTaps = 0;
    storeCalls = [];
    PackageInfo.setMockInitialValues(
      appName: 'medical',
      packageName: 'com.vbhc.diab',
      version: '2.5.1',
      buildNumber: '201',
      buildSignature: '',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_storeChannel, (call) async {
      storeCalls.add(call);
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_storeChannel, null);
    await cubit.close();
  });

  /// Mounts the gate the way lib/src/app.dart does: in MaterialApp.builder,
  /// above the Navigator.
  Future<void> pumpGate(WidgetTester tester, {bool enabled = true}) async {
    await pumpLocalized(
      tester,
      builder: (context, child) =>
          ForceUpdateGate(cubit: cubit, enabled: enabled, child: child!),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            key: _childButtonKey,
            onPressed: () => childTaps++,
            child: const Text('child'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ForceUpdateGate', () {
    testWidgets('not required => child visible and usable, no dialog',
        (tester) async {
      deps.required = '2.5.1';
      await pumpGate(tester);

      expect(cubit.state, isA<ForceUpdateNotRequired>());
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      await tester.tap(find.byKey(_childButtonKey));
      expect(childTaps, 1);
    });

    testWidgets(
        'required => dialog with required version, child taps are blocked',
        (tester) async {
      await pumpGate(tester);

      expect(cubit.state, isA<ForceUpdateRequired>());
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      // Localized message (langs.csv `mes_force_update_required`) carries the
      // required version as its {} argument.
      expect(find.textContaining('2.6.0'), findsOneWidget);
      expect(find.text('Cập nhật'), findsNWidgets(2)); // title + action

      // Child stays mounted (state preserved) but is unreachable.
      expect(find.byKey(_childButtonKey), findsOneWidget);
      await tester.tap(find.byKey(_childButtonKey), warnIfMissed: false);
      await tester.pump();
      expect(childTaps, 0);
    });

    testWidgets('tapping "Cập nhật" opens the store and keeps the dialog',
        (tester) async {
      await pumpGate(tester);

      await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Cập nhật'));
      await tester.pumpAndSettle();

      expect(storeCalls, hasLength(1));
      expect(storeCalls.single.method, 'redirect');
      expect(
          (storeCalls.single.arguments as Map)['android_id'], 'com.vbhc.diab');
      expect(find.byType(CupertinoAlertDialog), findsOneWidget,
          reason: 'there is no dismiss path; only a resume re-check clears it');
    });

    testWidgets(
        'app resumed => check(refresh: true), dialog not stacked; '
        'clears once the app is up to date', (tester) async {
      await pumpGate(tester);
      expect(deps.refreshCalls, 0);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(deps.refreshCalls, 1);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);

      // User updated in the store (or RC lowered the minimum) and comes back.
      deps.current = '2.6.0';
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(deps.refreshCalls, 2);
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      await tester.tap(find.byKey(_childButtonKey));
      expect(childTaps, 1);
    });

    testWidgets('enabled: false => never checks, not even on resume',
        (tester) async {
      await pumpGate(tester, enabled: false);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(deps.currentCalls, 0);
      expect(deps.refreshCalls, 0);
      expect(cubit.state, isA<ForceUpdateInitial>());
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      await tester.tap(find.byKey(_childButtonKey));
      expect(childTaps, 1);
    });
  });
}
