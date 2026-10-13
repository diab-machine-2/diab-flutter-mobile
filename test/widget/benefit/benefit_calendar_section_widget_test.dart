@Tags(['ui'])
library;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/benefit/benefit_calendar_section.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';

import '../../fakes/fake_dsmes_app_repository.dart';
import '../../helpers/localized_app.dart';
import '../../helpers/test_user.dart';

// Telemedicine clinic resolution in BenefitCalendarSection
// (lib/src/widget/benefit/benefit_calendar_section.dart `_resolveClinicFromIds`):
// fetch `api/clinics/profile` for clinicIds.first directly and accept it only
// if it succeeded AND the clinic offers telemedicine (`sv_available`);
// otherwise fall back to the clinic search (filtered on
// sv_available=telemedicine), then fetch detail for its first hit.

/// Clinic profile JSON; [telemedicine] controls `sv_available`.
Map<String, dynamic> _clinic(int id, String name, {bool telemedicine = true}) =>
    {
      'id': id,
      'name': name,
      'sv_available': [
        {'key': 'at_clinic', 'name': 'Tại phòng khám'},
        if (telemedicine) {'key': 'telemedicine', 'name': 'Khám từ xa'},
      ],
    };

const _noClinicText = 'Chưa có nơi khám phù hợp yêu cầu'; // empty_clinic_content (vi)

void main() {
  late FakeDsmesAppRepository repo;
  late DsmesAppointmentCubit cubit;
  late List<DsmesAppointmentState> states;

  setUpAll(() async {
    await initTestLocalization();
    AppSettings.userInfo = buildTestUser();
  });

  setUp(() {
    repo = FakeDsmesAppRepository();
    cubit = DsmesAppointmentCubit(repo)..isBenefitFlow = true;
    states = [];
    cubit.stream.listen(states.add);
  });

  tearDown(() => cubit.close());

  /// The section's shimmer AnimationController repeats forever, so
  /// pumpAndSettle would never return — pump the fake async work instead.
  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpSection(WidgetTester tester, List<String> clinicIds) async {
    await pumpLocalized(
      tester,
      // Same as lib/src/app.dart: the section calls BotToast.closeAllLoading.
      builder: BotToastInit(),
      home: BlocProvider<DsmesAppointmentCubit>.value(
        value: cubit,
        child: BenefitCalendarSection(
          serviceType: DsmesAppointmentMode.telemedicine.toString(),
          bookingType: Const.BENEFIT_BOOKING_TELEMEDICINE,
          specialtyName: 'Nội tiết',
          clinicIds: clinicIds,
        ),
      ),
    );
    await pumpFrames(tester);
  }

  group('BenefitCalendarSection telemedicine clinic resolution', () {
    testWidgets(
        'direct detail succeeds with telemedicine => search is never called',
        (tester) async {
      repo.clinicsById[101] = _clinic(101, 'Clinic A');
      await pumpSection(tester, ['101', '202']);

      expect(repo.callLog, ['detail:101']);
      expect(repo.searchCalls, isEmpty);
      expect(cubit.selectedClinic?.id, 101);
      expect(cubit.createDsmesBookingRequest?.clinicId, 101,
          reason: 'booking request is built once the clinic resolves');
      expect(states.whereType<DsmesAppointmentFailure>(), isEmpty);
      expect(find.text(_noClinicText), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'direct detail succeeds but clinic has no telemedicine => falls back '
        'to search and books the search hit instead', (tester) async {
      repo.clinicsById[101] =
          _clinic(101, 'At-clinic only', telemedicine: false);
      repo.clinicsById[303] = _clinic(303, 'Telemedicine clinic');
      repo.searchProviders = [
        {'id': 303, 'name': 'Telemedicine clinic'},
      ];
      await pumpSection(tester, ['101', '303']);

      expect(repo.callLog, ['detail:101', 'search', 'detail:303']);
      expect(repo.searchCalls.single.svAvailable, ['telemedicine']);
      expect(cubit.selectedClinic?.id, 303);
      expect(cubit.createDsmesBookingRequest?.clinicId, 303,
          reason: 'must not book the clinic without telemedicine');
      expect(states.whereType<DsmesAppointmentFailure>(), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'direct detail fails => silent (no Failure state), falls back to '
        'search, then fetches detail of the first search hit', (tester) async {
      repo.clinicsById[303] = _clinic(303, 'Clinic From Search');
      repo.searchProviders = [
        {'id': 303, 'name': 'Clinic From Search'},
        {'id': 404, 'name': 'Other'},
      ];
      await pumpSection(tester, ['999', '303']);

      expect(repo.callLog, ['detail:999', 'search', 'detail:303']);
      expect(repo.searchCalls.single.clinicIds, ['999', '303']);
      expect(repo.searchCalls.single.svAvailable, ['telemedicine']);
      expect(cubit.selectedClinic?.id, 303);
      expect(cubit.createDsmesBookingRequest?.clinicId, 303);
      expect(states.whereType<DsmesAppointmentFailure>(), isEmpty,
          reason: 'the direct fetch is allowed to fail; it must not surface '
              'an error toast');
      expect(tester.takeException(), isNull);
    });

    testWidgets('non-numeric first id => goes straight to search',
        (tester) async {
      repo.clinicsById[303] = _clinic(303, 'Clinic From Search');
      repo.searchProviders = [
        {'id': 303, 'name': 'Clinic From Search'},
      ];
      await pumpSection(tester, ['abc']);

      expect(repo.callLog, ['search', 'detail:303']);
      expect(cubit.selectedClinic?.id, 303);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'direct detail fails and search is empty => "no clinic" message with '
        'retry', (tester) async {
      repo.searchProviders = [];
      await pumpSection(tester, ['999']);

      expect(repo.callLog, ['detail:999', 'search']);
      expect(find.text(_noClinicText), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retry re-runs the direct fetch first', (tester) async {
      repo.searchProviders = [];
      await pumpSection(tester, ['999']);
      expect(repo.callLog, ['detail:999', 'search']);

      repo.clinicsById[999] = _clinic(999, 'Back online');
      await tester.tap(find.byType(TextButton));
      await pumpFrames(tester);

      expect(repo.callLog, ['detail:999', 'search', 'detail:999']);
      expect(cubit.selectedClinic?.id, 999);
      expect(find.text(_noClinicText), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
