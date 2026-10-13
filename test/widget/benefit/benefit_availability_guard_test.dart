import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/app.dart' show navigatorKey;
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/benefit/benefit_availability_guard.dart';

/// Counts 'refresh_home' notifications — the observable side effect of
/// BenefitAvailabilityGuard.handleUnavailable (no navigator is mounted in
/// these unit tests, so the dialog/popUntil steps are skipped).
class _RefreshHomeSpy with Observer {
  int count = 0;

  @override
  update(Observable observable, String? notifyName, Map? map) {
    if (notifyName == 'refresh_home') count++;
  }
}

ApiResult<MyBenefitResponse> _withBundle() => ApiResult.success(
    data: MyBenefitResponse.fromJson(<String, dynamic>{
      'data': <String, dynamic>{'id': 'bundle-1'}
    }));

ApiResult<MyBenefitResponse> _noBundle() => ApiResult.success(
    data: MyBenefitResponse.fromJson(<String, dynamic>{'data': null}));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RefreshHomeSpy spy;
  late int calls;
  late ApiResult<MyBenefitResponse> next;
  late DateTime clock;

  setUp(() {
    BenefitAvailabilityGuard.resetForTest();
    calls = 0;
    next = _withBundle();
    clock = DateTime(2026, 1, 1, 9);
    BenefitAvailabilityGuard.fetchMyBenefit = () async {
      calls++;
      return next;
    };
    BenefitAvailabilityGuard.now = () => clock;
    spy = _RefreshHomeSpy();
    Observable.instance.addObserver(spy);
  });

  tearDown(() {
    Observable.instance.removeObserver(spy);
    BenefitAvailabilityGuard.resetForTest();
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('bundle present => true, no unavailable handling', () async {
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isTrue);
    await flush();
    expect(spy.count, 0);
  });

  test('success with data == null => false + handleUnavailable', () async {
    next = _noBundle();
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isFalse);
    await flush();
    expect(spy.count, 1);
  });

  test('404 NotFound => false + handleUnavailable', () async {
    next = const ApiResult.failure(error: NetworkExceptions.notFound('gone'));
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isFalse);
    await flush();
    expect(spy.count, 1);
  });

  for (final error in const <NetworkExceptions>[
    // handleResponse maps 400/401/403 (e.g. expired token) to these — must
    // not be shown as "benefit removed".
    NetworkExceptions.badRequest(),
    NetworkExceptions.unauthorizedRequest('Token expired'),
    NetworkExceptions.noInternetConnection(),
    NetworkExceptions.requestTimeout(),
    NetworkExceptions.sendTimeout(),
    NetworkExceptions.internalServerError(),
    NetworkExceptions.serviceUnavailable(),
    NetworkExceptions.unexpectedError(),
  ]) {
    test('${error.runtimeType} => true (not treated as "benefit removed")',
        () async {
      next = ApiResult.failure(error: error);
      expect(await BenefitAvailabilityGuard.ensureAvailable(), isTrue);
      await flush();
      expect(spy.count, 0);
    });
  }

  test('thrown exception => true', () async {
    BenefitAvailabilityGuard.fetchMyBenefit = () async => throw Exception('x');
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isTrue);
  });

  test('confirmed success is cached for 60 s', () async {
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isTrue);
    clock = clock.add(const Duration(seconds: 59));
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isTrue);
    expect(calls, 1);

    clock = clock.add(const Duration(seconds: 2));
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isTrue);
    expect(calls, 2);
  });

  test('network failure is not cached', () async {
    next = const ApiResult.failure(
        error: NetworkExceptions.noInternetConnection());
    await BenefitAvailabilityGuard.ensureAvailable();
    await BenefitAvailabilityGuard.ensureAvailable();
    expect(calls, 2);
  });

  test('concurrent calls share one request', () async {
    final results = await Future.wait([
      BenefitAvailabilityGuard.ensureAvailable(),
      BenefitAvailabilityGuard.ensureAvailable(),
    ]);
    expect(results, [true, true]);
    expect(calls, 1);
  });

  test('invalidate() forces a re-check', () async {
    await BenefitAvailabilityGuard.ensureAvailable();
    BenefitAvailabilityGuard.invalidate();
    await BenefitAvailabilityGuard.ensureAvailable();
    expect(calls, 2);
  });

  test('handleUnavailable clears the cache and refreshes Home once',
      () async {
    await BenefitAvailabilityGuard.ensureAvailable();
    await BenefitAvailabilityGuard.handleUnavailable();
    await BenefitAvailabilityGuard.ensureAvailable();
    expect(calls, 2);
    expect(spy.count, 1);
  });

  test('cool-down: a second handleUnavailable within 5 s is ignored',
      () async {
    await BenefitAvailabilityGuard.handleUnavailable();
    clock = clock.add(const Duration(seconds: 4));
    await BenefitAvailabilityGuard.handleUnavailable();
    expect(spy.count, 1);

    clock = clock.add(const Duration(seconds: 2));
    await BenefitAvailabilityGuard.handleUnavailable();
    expect(spy.count, 2);
  });

  test('cool-down also covers ensureAvailable-triggered handling', () async {
    next = _noBundle();
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isFalse);
    await flush();
    expect(await BenefitAvailabilityGuard.ensureAvailable(), isFalse);
    await flush();
    expect(spy.count, 1);
  });

  group('with a navigator', () {
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(navigatorKey: navigatorKey, home: const Text('root')));
    }

    Future<void> push(WidgetTester tester, Route<void> route) async {
      navigatorKey.currentState!.push(route);
      await tester.pumpAndSettle();
    }

    testWidgets(
        'late result for an inactive origin route => refresh only, no '
        'dialog, no pop', (tester) async {
      await pumpApp(tester);
      final origin = MaterialPageRoute<void>(builder: (_) => const Text('a'));
      await push(tester, origin);
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      await push(tester,
          MaterialPageRoute<void>(builder: (_) => const Text('unrelated')));
      expect(origin.isActive, isFalse);

      next = _noBundle();
      expect(await BenefitAvailabilityGuard.ensureAvailable(origin: origin),
          isFalse);
      await tester.pumpAndSettle();

      expect(find.text('unrelated'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(spy.count, 1);
    });

    testWidgets('silent => refresh only, no dialog, no pop', (tester) async {
      await pumpApp(tester);
      await push(
          tester, MaterialPageRoute<void>(builder: (_) => const Text('top')));

      await BenefitAvailabilityGuard.handleUnavailable(silent: true);
      await tester.pumpAndSettle();

      expect(find.text('top'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(spy.count, 1);
    });
  });
}
