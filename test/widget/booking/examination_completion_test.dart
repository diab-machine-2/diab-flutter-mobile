import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/complete_smart_goal_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';

class _FakeRepo implements AppRepository {
  final requests = <CompleteSmartGoalRequest>[];

  @override
  Future<ApiResult<CommonResponse>> completeSmartGoal(
      CompleteSmartGoalRequest request) async {
    requests.add(request);
    return ApiResult.success(data: CommonResponse());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _FakeRepo repo;
  late DsmesAppointmentCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = DsmesAppointmentCubit(repo);
  });

  tearDown(() => cubit.close());

  void startFromActivity() => cubit.setExaminationData(
        isExamination: true,
        examinationType: 'HbA1C',
        examinationLocation: Const.EXAMINATION_LOCATION_CLINIC,
        smartGoalId: 'goal-1',
        smartGoalExecuteDayTimes: 1,
        smartGoalAppointmentDate: 1792454400,
      );

  test('booking created: completes the activity like other activities', () async {
    startFromActivity();

    await cubit.completeExaminationActivity();

    final request = repo.requests.single;
    expect(request.id, 'goal-1');
    expect(request.type, 35);
    expect(request.executeTimes, 1);
    expect(request.appointmentDate, 1792454400);
  });

  test('picking a clinic later keeps the activity being booked', () async {
    startFromActivity();
    // The clinic list re-sets the flow without the activity.
    cubit.setExaminationData(
      isExamination: true,
      examinationType: 'HbA1C',
      examinationLocation: Const.EXAMINATION_LOCATION_CLINIC,
    );

    await cubit.completeExaminationActivity();

    expect(repo.requests.single.id, 'goal-1');
    expect(repo.requests.single.appointmentDate, 1792454400);
  });

  test('completes once even if both booking paths report success', () async {
    startFromActivity();

    await cubit.completeExaminationActivity();
    await cubit.completeExaminationActivity();

    expect(repo.requests, hasLength(1));
  });

  test('a normal booking (not from an activity) completes nothing', () async {
    startFromActivity();
    cubit.clearExaminationData();

    await cubit.completeExaminationActivity();

    expect(repo.requests, isEmpty);
  });
}
