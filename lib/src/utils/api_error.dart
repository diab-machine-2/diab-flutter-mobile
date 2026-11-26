import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart' as api;
import 'package:medical/src/utils/const.dart';

/// Why an API call failed, as far as the user is concerned.
enum ApiFailureKind {
  /// No connection / the request never reached the server.
  network,

  /// The server failed (5xx) or answered something the app can't read.
  server,
}

bool isServerErrorStatus(int? statusCode) =>
    statusCode != null && statusCode >= 500 && statusCode < 600;

ApiFailureKind apiFailureKind(Object error) {
  if (error is SocketException ||
      error is HandshakeException ||
      error is TimeoutException) {
    return ApiFailureKind.network;
  }
  if (error is DioException) {
    switch (error.type) {
      // Timeouts count as network: the user can't tell them apart and the
      // fix on their side (check the connection) is the same.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return ApiFailureKind.network;
      case DioExceptionType.unknown:
        final inner = error.error;
        if (inner is SocketException || inner is HandshakeException) {
          return ApiFailureKind.network;
        }
        return ApiFailureKind.server;
      default:
        return ApiFailureKind.server;
    }
  }
  return ApiFailureKind.server;
}

/// "Không có kết nối mạng" / "Hệ thống đang gặp sự cố".
String apiFailureMessage(ApiFailureKind kind) => kind == ApiFailureKind.network
    ? R.string.error_no_network_connection.tr()
    : R.string.error_system_problem.tr();

/// User-facing message for any error caught around an API call.
/// - A backend business error ([api.Error]) keeps its own message.
/// - A message already mapped by a client (a [String]) is passed through.
/// - Everything else: network vs system problem.
String apiErrorMessage(Object? error) {
  if (error is api.Error && (error.message?.isNotEmpty ?? false)) {
    return error.message!;
  }
  if (error is String && error.isNotEmpty) return error;
  if (error == null || error is api.Error || error is String) {
    return apiFailureMessage(ApiFailureKind.server);
  }
  return apiFailureMessage(apiFailureKind(error));
}

/// What legacy clients throw from their catch blocks: a backend [api.Error]
/// as-is (callers read its code), otherwise the mapped message.
Object apiFailure(Object error) =>
    error is api.Error ? error : apiErrorMessage(error);

/// Reports every 5xx to Crashlytics as a non-fatal, on production only
/// (staging fails often enough to drown the signal). Never changes the
/// request outcome: FetchClient accepts every status, so a 5xx reaches the
/// caller as a Response; Retrofit (AppClient) already throws it.
class ServerErrorInterceptor extends Interceptor {
  static bool get _reportEnabled => Const.ENVIRONMENT_DEFAULT == 'product';

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isServerErrorStatus(response.statusCode)) {
      _report(response.requestOptions, response.statusCode);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isServerErrorStatus(err.response?.statusCode)) {
      _report(err.requestOptions, err.response?.statusCode);
    }
    handler.next(err);
  }

  /// getUri() puts the whole URL (with query) in options.path.
  static String _pathOnly(RequestOptions options) =>
      Uri.tryParse(options.path)?.path ?? options.uri.path;

  static void _report(RequestOptions options, int? statusCode) {
    if (!_reportEnabled) return;
    try {
      FirebaseCrashlytics.instance.recordError(
        ServerErrorReport(options.method, _pathOnly(options), statusCode),
        StackTrace.current,
        reason: 'API $statusCode',
        fatal: false,
      );
    } catch (_) {
      // Reporting must never break the request.
    }
  }
}

/// Non-fatal Crashlytics entry for a 5xx. Path only (no query string), so
/// no user data is sent.
class ServerErrorReport implements Exception {
  ServerErrorReport(this.method, this.path, this.statusCode);

  final String method;
  final String path;
  final int? statusCode;

  @override
  String toString() => 'ServerError $statusCode $method $path';
}
