import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/benefit/benefit_introduce_bundle_cubit.dart';

// When a bundle is removed server-side, /my-benefit returns no data or a 404.
// The cubit maps both to BenefitIntroduceBundleUnavailable, which
// BenefitIntroduceBundlePage / BenefitMyVoucherPage hand to
// BenefitAvailabilityGuard.handleUnavailable (dialog + refresh Home + pop to
// the tab bar). Other errors (400/401/403, network, 5xx) stay
// BenefitIntroduceBundleFailure (empty view with pull-to-retry).

class _FakeRepo implements AppRepository {
  ApiResult<MyBenefitResponse> next = ApiResult.success(
      data: MyBenefitResponse.fromJson(<String, dynamic>{'data': null}));
  int calls = 0;

  @override
  Future<ApiResult<MyBenefitResponse>> getMyBenefit() async {
    calls++;
    return next;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<List<BenefitIntroduceBundleState>> _record(
    BenefitIntroduceBundleCubit cubit, Future<void> Function() body) async {
  final states = <BenefitIntroduceBundleState>[];
  final sub = cubit.stream.listen(states.add);
  await body();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  late _FakeRepo repo;
  late BenefitIntroduceBundleCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = BenefitIntroduceBundleCubit(repo);
  });

  tearDown(() => cubit.close());

  test('null data => Loading -> Unavailable', () async {
    final states = await _record(cubit, cubit.loadMyBenefit);
    expect(states, [
      isA<BenefitIntroduceBundleLoading>(),
      isA<BenefitIntroduceBundleUnavailable>(),
    ]);
    expect(cubit.benefitData, isNull);
  });

  test('404 NotFound => Loading -> Unavailable', () async {
    repo.next = const ApiResult.failure(
        error: NetworkExceptions.notFound('Bundle not found'));
    final states = await _record(cubit, cubit.loadMyBenefit);
    expect(states, [
      isA<BenefitIntroduceBundleLoading>(),
      isA<BenefitIntroduceBundleUnavailable>(),
    ]);
  });

  // handleResponse maps 400/401/403 (e.g. an expired token) to these — they
  // must not be shown as "benefit removed".
  for (final error in const <NetworkExceptions>[
    NetworkExceptions.badRequest(),
    NetworkExceptions.unauthorizedRequest('Token expired'),
  ]) {
    test('${error.runtimeType} => Loading -> Failure, not Unavailable',
        () async {
      repo.next = ApiResult.failure(error: error);
      final states = await _record(cubit, cubit.loadMyBenefit);
      expect(states, [
        isA<BenefitIntroduceBundleLoading>(),
        isA<BenefitIntroduceBundleFailure>(),
      ]);
    });
  }

  test('non-4xx failure => Loading -> Failure(message)', () async {
    repo.next = const ApiResult.failure(
        error: NetworkExceptions.defaultError('Server exploded'));
    final states = await _record(cubit, cubit.loadMyBenefit);
    expect(states, [
      isA<BenefitIntroduceBundleLoading>(),
      isA<BenefitIntroduceBundleFailure>()
          .having((s) => s.message, 'message', 'Server exploded'),
    ]);
  });

  test('refreshMyBenefit (pull-to-retry from the empty view) skips Loading',
      () async {
    repo.next = const ApiResult.failure(
        error: NetworkExceptions.defaultError('Server exploded'));
    await cubit.loadMyBenefit();
    final states = await _record(cubit, cubit.refreshMyBenefit);
    expect(states, [isA<BenefitIntroduceBundleFailure>()]);
    expect(repo.calls, 2);
  });
}
