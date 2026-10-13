import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';

import '../../fakes/fake_dsmes_app_repository.dart';

// Covers DsmesAppointmentCubit.getClinicDetail({id, isLoading, emitFailure})
// (lib/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart). The
// `emitFailure: false` mode is used by BenefitCalendarSection
// ._resolveClinicFromIds so a failed direct fetch falls back to the clinic
// search silently instead of surfacing an error toast.

Future<(bool, List<DsmesAppointmentState>)> _run(
    DsmesAppointmentCubit cubit, Future<bool> Function() body) async {
  final states = <DsmesAppointmentState>[];
  final sub = cubit.stream.listen(states.add);
  final result = await body();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return (result, states);
}

void main() {
  late FakeDsmesAppRepository repo;
  late DsmesAppointmentCubit cubit;

  setUp(() {
    repo = FakeDsmesAppRepository()
      ..clinicsById[101] = {'id': 101, 'name': 'Clinic A', 'address': 'HCM'};
    cubit = DsmesAppointmentCubit(repo);
  });

  tearDown(() => cubit.close());

  group('getClinicDetail success', () {
    test('Loading -> Loaded, selects the clinic, returns true', () async {
      final (ok, states) =
          await _run(cubit, () => cubit.getClinicDetail(id: 101));
      expect(ok, isTrue);
      expect(states,
          [isA<DsmesAppointmentLoading>(), isA<DsmesAppointmentLoaded>()]);
      expect(cubit.selectedClinic?.id, 101);
      expect(cubit.selectedClinic?.name, 'Clinic A');
      expect(repo.detailCalls, [101]);
    });

    test('isLoading: false => only Loaded', () async {
      final (ok, states) = await _run(
          cubit, () => cubit.getClinicDetail(id: 101, isLoading: false));
      expect(ok, isTrue);
      expect(states, [isA<DsmesAppointmentLoaded>()]);
    });

    test('emitFailure: false does not change the success path', () async {
      final (ok, states) = await _run(
          cubit, () => cubit.getClinicDetail(id: 101, emitFailure: false));
      expect(ok, isTrue);
      expect(states,
          [isA<DsmesAppointmentLoading>(), isA<DsmesAppointmentLoaded>()]);
    });
  });

  group('getClinicDetail failure', () {
    test('default (emitFailure: true) => Loading -> Failure(message), false',
        () async {
      final (ok, states) =
          await _run(cubit, () => cubit.getClinicDetail(id: 999));
      expect(ok, isFalse);
      expect(states, [
        isA<DsmesAppointmentLoading>(),
        isA<DsmesAppointmentFailure>()
            .having((s) => s.error, 'error', 'clinic not found'),
      ]);
      expect(cubit.selectedClinic, isNull);
    });

    test(
        'emitFailure: false => Loading -> Loaded (no Failure, so no error '
        'toast), returns false', () async {
      final (ok, states) = await _run(
          cubit, () => cubit.getClinicDetail(id: 999, emitFailure: false));
      expect(ok, isFalse);
      expect(states,
          [isA<DsmesAppointmentLoading>(), isA<DsmesAppointmentLoaded>()]);
      expect(states.whereType<DsmesAppointmentFailure>(), isEmpty);
      expect(cubit.selectedClinic, isNull);
    });

    test('emitFailure: false + isLoading: false => just Loaded', () async {
      final (ok, states) = await _run(
          cubit,
          () => cubit.getClinicDetail(
              id: 999, isLoading: false, emitFailure: false));
      expect(ok, isFalse);
      expect(states, [isA<DsmesAppointmentLoaded>()]);
    });

    test('a failure does not clear a previously selected clinic', () async {
      await cubit.getClinicDetail(id: 101);
      repo.detailError = const NetworkExceptions.notFound('gone');
      final ok = await cubit.getClinicDetail(id: 999, emitFailure: false);
      expect(ok, isFalse);
      // Documented behaviour: selectedClinic keeps the old value — callers
      // must check the returned bool, not just selectedClinic != null.
      expect(cubit.selectedClinic?.id, 101);
    });
  });
}
