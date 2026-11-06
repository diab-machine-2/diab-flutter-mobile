import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/booking_check_response.dart';

// BE-7 payloads as staging returns them (03–04/11/2026).
void main() {
  group('BookingCheckResponse.fromJson', () {
    test('allowed with quota left', () {
      final r = BookingCheckResponse.fromJson({
        'meta': {'success': true},
        'data': {
          'mode': 'offline',
          'allowed': true,
          'isUnlimited': false,
          'remaining': 3,
          'message': null,
        },
      });
      expect(r.success, isTrue);
      expect(r.data!.allowed, isTrue);
      expect(r.data!.remaining, 3);
      expect(r.data!.mode, 'offline');
    });

    test('unlimited bundle reports remaining 0 but allowed', () {
      final r = BookingCheckResponse.fromJson({
        'meta': {'success': true},
        'data': {'mode': 'online', 'allowed': true, 'isUnlimited': true,
          'remaining': 0},
      });
      expect(r.data!.allowed, isTrue);
      expect(r.data!.isUnlimited, isTrue);
      expect(r.data!.remaining, 0);
    });

    test('out of quota carries the backend message', () {
      final r = BookingCheckResponse.fromJson({
        'meta': {'success': true},
        'data': {'mode': 'offline', 'allowed': false, 'isUnlimited': false,
          'remaining': 0, 'message': 'Đã hết lượt đặt'},
      });
      expect(r.data!.allowed, isFalse);
      expect(r.data!.message, 'Đã hết lượt đặt');
    });

    test('failure is HTTP 200 with meta.success false', () {
      final r = BookingCheckResponse.fromJson({
        'meta': {'success': false},
        'error': {
          'code': 'exception',
          'message': 'Loại đặt khám không hợp lệ, chỉ nhận online hoặc offline',
        },
      });
      expect(r.success, isFalse);
      expect(r.data, isNull);
      expect(r.errorMessage, contains('online hoặc offline'));
    });

    test('remaining as a double and missing fields do not throw', () {
      final r = BookingCheckResponse.fromJson({
        'meta': {'success': true},
        'data': {'remaining': 2.0},
      });
      expect(r.data!.remaining, 2);
      expect(r.data!.allowed, isFalse);
    });
  });

  test('benefitBookingMode: at clinic → offline, telemedicine → online', () {
    expect(AppRepository.benefitBookingMode(true), 'offline');
    expect(AppRepository.benefitBookingMode(false), 'online');
  });
}
