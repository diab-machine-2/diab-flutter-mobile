import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/benefit/benefit_availability_guard.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';

/// Before: submitMedicineRequest/submitLabTestRequest ignored the ApiResult
/// of both calls and always emitted SubmitSuccess (fake success). Now a
/// failed availability check / submit emits Unavailable/Error; once the
/// submit succeeds, a failing mark-used is only logged (SubmitSuccess).
class _FakeRepo implements AppRepository {
  ApiResult<CommonResponse> submitResult =
      ApiResult.success(data: CommonResponse());
  ApiResult<CommonResponse> useResult =
      ApiResult.success(data: CommonResponse());
  int submitCalls = 0;
  int useCalls = 0;

  @override
  Future<ApiResult<CommonResponse>> submitMedicationRequest(
      Map<String, dynamic> body) async {
    submitCalls++;
    return submitResult;
  }

  @override
  Future<ApiResult<CommonResponse>> useBenefitService({
    required String itemId,
    required int itemType,
  }) async {
    useCalls++;
    return useResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<List<BenefitServiceRequestState>> _record(
    BenefitServiceRequestCubit cubit, Future<void> Function() body) async {
  final states = <BenefitServiceRequestState>[];
  final sub = cubit.stream.listen(states.add);
  await body();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeRepo repo;
  late ApiResult<MyBenefitResponse> myBenefit;

  setUp(() {
    repo = _FakeRepo();
    BenefitAvailabilityGuard.resetForTest();
    myBenefit = ApiResult.success(
        data: MyBenefitResponse.fromJson(<String, dynamic>{
          'data': <String, dynamic>{'id': 'bundle-1'}
        }));
    BenefitAvailabilityGuard.fetchMyBenefit = () async => myBenefit;
  });

  tearDown(BenefitAvailabilityGuard.resetForTest);

  Future<void> submitMedicine(BenefitServiceRequestCubit c) =>
      c.submitMedicineRequest(
          selectedMedicines: const [],
          gptParsedResult: '',
          imageUrl: null,
          note: null);

  Future<void> submitLabTest(BenefitServiceRequestCubit c) =>
      c.submitLabTestRequest(
          selectedServices: const ['a'],
          diagnose: null,
          gptParsedResult: '',
          imageUrl: null,
          note: null);

  group('not from bundle', () {
    test('medicine success => Loading -> SubmitSuccess', () async {
      final cubit = BenefitServiceRequestCubit(repo);
      final states = await _record(cubit, () => submitMedicine(cubit));
      expect(states, [
        isA<BenefitServiceRequestLoading>(),
        isA<BenefitServiceRequestSubmitSuccess>(),
      ]);
      expect(repo.useCalls, 0);
      await cubit.close();
    });

    test('medicine submit failure => Error, not SubmitSuccess', () async {
      repo.submitResult = const ApiResult.failure(
          error: NetworkExceptions.defaultError('submit failed'));
      final cubit = BenefitServiceRequestCubit(repo);
      final states = await _record(cubit, () => submitMedicine(cubit));
      expect(states, [
        isA<BenefitServiceRequestLoading>(),
        isA<BenefitServiceRequestError>()
            .having((s) => s.message, 'message', 'submit failed'),
      ]);
      await cubit.close();
    });

    test('lab test submit failure => Error, not SubmitSuccess', () async {
      repo.submitResult = const ApiResult.failure(
          error: NetworkExceptions.defaultError('submit failed'));
      final cubit = BenefitServiceRequestCubit(repo);
      final states = await _record(cubit, () => submitLabTest(cubit));
      expect(states.last, isA<BenefitServiceRequestError>());
      expect(states.whereType<BenefitServiceRequestSubmitSuccess>(), isEmpty);
      await cubit.close();
    });

    test('user without a bundle still submits, my-benefit not called',
        () async {
      var benefitCalls = 0;
      BenefitAvailabilityGuard.fetchMyBenefit = () async {
        benefitCalls++;
        return ApiResult.success(
            data: MyBenefitResponse.fromJson(<String, dynamic>{'data': null}));
      };
      final cubit = BenefitServiceRequestCubit(repo);
      expect(cubit.fromBundle, isFalse);
      final states = await _record(cubit, () => submitLabTest(cubit));
      expect(states.last, isA<BenefitServiceRequestSubmitSuccess>());
      expect(benefitCalls, 0);
      await cubit.close();
    });
  });

  group('from bundle item', () {
    BenefitServiceRequestCubit bundleCubit() =>
        BenefitServiceRequestCubit(repo, itemId: 'item-1', itemType: 2);

    test('all calls succeed => SubmitSuccess and item marked used', () async {
      final cubit = bundleCubit();
      final states = await _record(cubit, () => submitLabTest(cubit));
      expect(states.last, isA<BenefitServiceRequestSubmitSuccess>());
      expect(repo.submitCalls, 1);
      expect(repo.useCalls, 1);
      await cubit.close();
    });

    test('bundle removed before submit => Unavailable, nothing submitted',
        () async {
      myBenefit = ApiResult.success(
          data: MyBenefitResponse.fromJson(<String, dynamic>{'data': null}));
      final cubit = bundleCubit();
      final states = await _record(cubit, () => submitMedicine(cubit));
      expect(states, [
        isA<BenefitServiceRequestLoading>(),
        isA<BenefitServiceRequestUnavailable>(),
      ]);
      expect(repo.submitCalls, 0);
      expect(repo.useCalls, 0);
      await cubit.close();
    });

    // The order is already sent once submit succeeds — a failing mark-used
    // must not surface Error/Unavailable (a retry would duplicate the order).
    for (final error in const <NetworkExceptions>[
      NetworkExceptions.notFound('Bundle removed'),
      NetworkExceptions.unauthorizedRequest('Token expired'),
      NetworkExceptions.defaultError('mark-used failed'),
    ]) {
      test(
          'useBenefitService ${error.runtimeType} after successful submit => '
          'SubmitSuccess, submitted once', () async {
        repo.useResult = ApiResult.failure(error: error);
        final cubit = bundleCubit();
        final states = await _record(cubit, () => submitMedicine(cubit));
        expect(states, [
          isA<BenefitServiceRequestLoading>(),
          isA<BenefitServiceRequestSubmitSuccess>(),
        ]);
        expect(repo.submitCalls, 1);
        expect(repo.useCalls, 1);
        await cubit.close();
      });
    }

    test('lab test: useBenefitService failure => SubmitSuccess', () async {
      repo.useResult = const ApiResult.failure(
          error: NetworkExceptions.defaultError('mark-used failed'));
      final cubit = bundleCubit();
      final states = await _record(cubit, () => submitLabTest(cubit));
      expect(states.last, isA<BenefitServiceRequestSubmitSuccess>());
      expect(states.whereType<BenefitServiceRequestError>(), isEmpty);
      expect(repo.submitCalls, 1);
      await cubit.close();
    });
  });
}
