import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/response/booking_check_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/benefit/benefit_booking_quota_gate.dart';

import '../../helpers/localized_app.dart';

ApiResult<BookingCheckResponse> _check(Map<String, dynamic> data,
        {bool success = true}) =>
    ApiResult.success(
        data: BookingCheckResponse.fromJson(<String, dynamic>{
      'meta': {'success': success},
      'data': data,
    }));

void main() {
  group('blockingCheck', () {
    late String? askedMode;

    void answer(ApiResult<BookingCheckResponse> result) {
      BenefitBookingQuotaGate.fetchCheck = (mode) async {
        askedMode = mode;
        return result;
      };
    }

    setUp(() => askedMode = null);

    test('allowed => null (go ahead)', () async {
      answer(_check({'mode': 'online', 'allowed': true, 'remaining': 2}));
      expect(await BenefitBookingQuotaGate.blockingCheck('online'), isNull);
      expect(askedMode, 'online');
    });

    test('allowed: false => the blocking answer with reason and message',
        () async {
      answer(_check({
        'mode': 'offline',
        'allowed': false,
        'reason': 'not_included',
        'message': 'Gói dịch vụ của bạn không bao gồm lượt đặt lịch này',
      }));
      final blocked = await BenefitBookingQuotaGate.blockingCheck('offline');
      expect(blocked, isNotNull);
      expect(blocked!.reason, 'not_included');
      expect(blocked.hasNoBundle, isFalse);
      expect(blocked.message, contains('không bao gồm'));
    });

    test('meta.success false => null (unknown, let the user through)',
        () async {
      answer(_check({'allowed': false}, success: false));
      expect(await BenefitBookingQuotaGate.blockingCheck('online'), isNull);
    });

    test('network error / missing endpoint => null', () async {
      answer(const ApiResult.failure(error: NetworkExceptions.notFound('404')));
      expect(await BenefitBookingQuotaGate.blockingCheck('online'), isNull);
    });
  });

  group('BenefitQuotaDialog', () {
    setUpAll(initTestLocalization);

    Future<void> pumpDialog(WidgetTester tester, BenefitQuotaDialog dialog) =>
        pumpLocalized(tester, home: Scaffold(body: Center(child: dialog)));

    testWidgets('quota used up: warning icon, title, fallback text, 2 buttons',
        (tester) async {
      await pumpDialog(
          tester,
          BenefitQuotaDialog(
              check: BookingCheckData(mode: 'online', allowed: false)));
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Đã hết lượt đặt'), findsOneWidget);
      expect(find.text('Đã hết số lượt sử dụng dịch vụ'), findsOneWidget);
      expect(find.text('Đóng'), findsOneWidget);
      expect(find.text('Xem quyền lợi'), findsOneWidget);
    });

    testWidgets('not_included: "Chưa thể đặt lịch" + backend message',
        (tester) async {
      await pumpDialog(
          tester,
          BenefitQuotaDialog(
              check: BookingCheckData(
                  allowed: false,
                  reason: 'not_included',
                  message:
                      'Gói dịch vụ của bạn không bao gồm lượt đặt lịch này')));
      expect(find.text('Chưa thể đặt lịch'), findsOneWidget);
      expect(find.text('Gói dịch vụ của bạn không bao gồm lượt đặt lịch này'),
          findsOneWidget);
      expect(find.text('Xem quyền lợi'), findsOneWidget);
    });

    testWidgets('no_bundle: no "Xem quyền lợi" (nothing to show)',
        (tester) async {
      await pumpDialog(
          tester,
          BenefitQuotaDialog(
              check: BookingCheckData(allowed: false, reason: 'no_bundle')));
      expect(find.text('Chưa thể đặt lịch'), findsOneWidget);
      expect(find.text('Đóng'), findsOneWidget);
      expect(find.text('Xem quyền lợi'), findsNothing);
    });

    testWidgets('showViewBenefits false (bundle page): only "Đóng"',
        (tester) async {
      await pumpDialog(tester,
          const BenefitQuotaDialog(showViewBenefits: false));
      expect(find.text('Đã hết lượt đặt'), findsOneWidget);
      expect(find.text('Xem quyền lợi'), findsNothing);
    });
  });
}
