import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/clinic_specialty_list_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widget/booking_clinic/specialty_list_cubit.dart';

class _FakeRepo implements AppRepository {
  ApiResult<ClinicSpecialtyListResponse> result = ApiResult.success(
      data: ClinicSpecialtyListResponse(code: 0, data: [], attr: null));
  int calls = 0;

  @override
  Future<ApiResult<ClinicSpecialtyListResponse>>
      getCLinicSpecialtyListDiab() async {
    calls++;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  final specialties = [
    ClinicSpecialty(id: 17, name: 'Đái tháo đường'),
    ClinicSpecialty(id: 0, name: 'Cơ xương khớp'),
  ];

  test('success → arranged list, passing the booking type', () async {
    final repo = _FakeRepo()
      ..result = ApiResult.success(
          data: ClinicSpecialtyListResponse(
              code: 0, data: specialties, attr: null));
    bool? seenTelemedicine;
    final cubit = SpecialtyListCubit(
      repo,
      isTelemedicine: true,
      arrange: (list, {required isTelemedicine}) {
        seenTelemedicine = isTelemedicine;
        return list.reversed.toList();
      },
    );

    final states = <SpecialtyListState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states.first, isA<SpecialtyListLoading>());
    final success = states.last as SpecialtyListSuccess;
    expect(success.specialties.map((s) => s.id), [0, 17]);
    expect(seenTelemedicine, isTrue);
    await sub.cancel();
    await cubit.close();
  });

  test('failure → error state; retry calls the API again', () async {
    final repo = _FakeRepo()
      ..result = const ApiResult.failure(
          error: NetworkExceptions.noInternetConnection());
    final cubit = SpecialtyListCubit(repo,
        isTelemedicine: false,
        arrange: (list, {required isTelemedicine}) => list);

    await cubit.load();
    expect(cubit.state, isA<SpecialtyListError>());

    repo.result = ApiResult.success(
        data: ClinicSpecialtyListResponse(
            code: 0, data: specialties, attr: null));
    await cubit.load();
    expect(cubit.state, isA<SpecialtyListSuccess>());
    expect(repo.calls, 2);
    await cubit.close();
  });

  test('arrange throwing → API order, not stuck loading', () async {
    final repo = _FakeRepo()
      ..result = ApiResult.success(
          data: ClinicSpecialtyListResponse(
              code: 0, data: specialties, attr: null));
    final cubit = SpecialtyListCubit(repo,
        isTelemedicine: false,
        arrange: (list, {required isTelemedicine}) => throw StateError('rc'));
    await cubit.load();
    final state = cubit.state as SpecialtyListSuccess;
    expect(state.specialties.map((s) => s.id), [17, 0]);
    await cubit.load();
    expect(repo.calls, 2);
    await cubit.close();
  });

  test('close during the request does not emit after close', () async {
    final repo = _FakeRepo();
    final cubit = SpecialtyListCubit(repo,
        isTelemedicine: false,
        arrange: (list, {required isTelemedicine}) => list);
    final pending = cubit.load();
    await cubit.close();
    await pending;
    expect(cubit.isClosed, isTrue);
  });
}
