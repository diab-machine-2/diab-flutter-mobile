import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/modal/error/error_model.dart' as api;
import 'package:medical/src/model/ai_recommendation_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart'
    hide FormatException;
import 'package:medical/src/utils/api_error.dart';

// Without easy_localization loaded, .tr() returns the key, so the tests
// assert on keys: error_system_problem ("Hệ thống đang gặp sự cố") and
// error_no_network_connection ("Không có kết nối mạng").
const _system = 'error_system_problem';
const _network = 'error_no_network_connection';

DioException _dio(DioExceptionType type, {int? status, Object? error}) {
  final options = RequestOptions(path: '/App/BloodPressure/Trend');
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('apiErrorMessage', () {
    test('no connection → network message', () {
      expect(apiErrorMessage(const SocketException('offline')), _network);
      expect(apiErrorMessage(_dio(DioExceptionType.connectionError)), _network);
      expect(
          apiErrorMessage(_dio(DioExceptionType.connectionTimeout)), _network);
      expect(apiErrorMessage(_dio(DioExceptionType.receiveTimeout)), _network);
      expect(
          apiErrorMessage(_dio(DioExceptionType.unknown,
              error: const SocketException('x'))),
          _network);
    });

    test('5xx and unreadable responses → system message', () {
      expect(apiErrorMessage(_dio(DioExceptionType.badResponse, status: 500)),
          _system);
      // A 5xx text body used to blow up in Error.fromJson with a TypeError.
      expect(apiErrorMessage(TypeError()), _system);
      expect(apiErrorMessage(const FormatException('bad json')), _system);
    });

    test('backend business error keeps its own message', () {
      final e = api.Error(code: 'USER002', message: 'Số điện thoại đã tồn tại',
          error: null);
      expect(apiErrorMessage(e), 'Số điện thoại đã tồn tại');
      expect(apiFailure(e), same(e));
    });

    test('a message already mapped by a client passes through', () {
      expect(apiErrorMessage(_network), _network);
      expect(apiFailure(_system), _system);
    });
  });

  group('Error.fromServerStatus', () {
    test('any 5xx → system message with an HTTP_ code', () {
      for (final status in [500, 502, 503, 504]) {
        final e = api.Error.fromServerStatus(status)!;
        expect(e.message, _system);
        expect(e.code, 'HTTP_$status');
      }
    });

    test('non-5xx is not a server error', () {
      for (final status in [null, 200, 400, 401, 404]) {
        expect(api.Error.fromServerStatus(status), isNull);
      }
    });

    test('Error.fromJson on a 500 with a plain-text crash dump', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/App/BloodPressure/Trend'),
        statusCode: 500,
        data: 'System.NullReferenceException: Object reference not set',
      );
      expect(api.Error.fromJson(response).message, _system);
    });
  });

  group('AiRecommendationResult.failure', () {
    test('ends the AI loading state with the classified message', () {
      final offline =
          AiRecommendationResult.failure(const SocketException('offline'));
      expect(offline.recommendation, isEmpty);
      expect(offline.errorMessage, _network);

      expect(AiRecommendationResult.failure(null).errorMessage, _system);
      expect(
          AiRecommendationResult.failure(api.Error.fromServerStatus(500))
              .errorMessage,
          _system);
    });

    test('Retrofit failures (weight / exercise AI) keep their classification',
        () {
      expect(
          AiRecommendationResult.failure(
                  const NetworkExceptions.noInternetConnection())
              .errorMessage,
          _network);
      expect(
          AiRecommendationResult.failure(
                  const NetworkExceptions.internalServerError())
              .errorMessage,
          _system);
    });

    test('a normal result carries no error', () {
      expect(AiRecommendationResult(recommendation: 'ok').errorMessage, isNull);
    });
  });

  group('NetworkExceptions (Retrofit clients)', () {
    String messageOf(Object error) => NetworkExceptions.getErrorMessage(
        NetworkExceptions.getDioException(error));

    test('500 / 502 → system message', () {
      expect(messageOf(_dio(DioExceptionType.badResponse, status: 500)),
          _system);
      expect(messageOf(_dio(DioExceptionType.badResponse, status: 502)),
          _system);
    });

    test('offline → network message', () {
      expect(messageOf(_dio(DioExceptionType.connectionError)), _network);
      expect(
          messageOf(_dio(DioExceptionType.unknown,
              error: const SocketException('x'))),
          _network);
    });

    test('unknown non-socket failure is not reported as offline', () {
      expect(
          messageOf(_dio(DioExceptionType.unknown,
              error: const FormatException('x'))),
          _system);
    });
  });
}
