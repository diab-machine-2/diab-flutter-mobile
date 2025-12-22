import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';

import '../app_api.dart';

const _defaultConnectTimeout = Duration.millisecondsPerMinute;
const _defaultReceiveTimeout = Duration.millisecondsPerMinute;

/// Custom logging interceptor that handles long responses without truncation
class FullLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('*** Request ***');
    debugPrint('uri: ${options.uri}');
    debugPrint('method: ${options.method}');
    debugPrint('responseType: ${options.responseType}');
    debugPrint('followRedirects: ${options.followRedirects}');
    debugPrint('connectTimeout: ${options.connectTimeout}');
    debugPrint('sendTimeout: ${options.sendTimeout}');
    debugPrint('receiveTimeout: ${options.receiveTimeout}');
    debugPrint(
        'receiveDataWhenStatusError: ${options.receiveDataWhenStatusError}');
    debugPrint('extra: ${options.extra}');
    debugPrint('headers:');
    options.headers.forEach((key, value) {
      debugPrint(' $key: $value');
    });
    debugPrint('data:');
    if (options.data != null) {
      _printLongMessage(options.data.toString());
    } else {
      debugPrint('null');
    }
    debugPrint('');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('*** Response ***');
    debugPrint('uri: ${response.requestOptions.uri}');
    debugPrint('statusCode: ${response.statusCode}');
    debugPrint('headers:');
    response.headers.forEach((key, values) {
      debugPrint(' $key: ${values.join(', ')}');
    });
    debugPrint('Response Text:');
    if (response.data != null) {
      String responseText;
      if (response.data is String) {
        responseText = response.data;
      } else {
        // Pretty print JSON
        try {
          responseText =
              const JsonEncoder.withIndent('  ').convert(response.data);
        } catch (e) {
          responseText = response.data.toString();
        }
      }
      _printLongMessage(responseText);
    } else {
      debugPrint('null');
    }
    debugPrint('');
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    debugPrint('*** Error ***');
    debugPrint('uri: ${err.requestOptions.uri}');
    debugPrint('error: ${err.error}');
    debugPrint('type: ${err.type}');
    if (err.response != null) {
      debugPrint('statusCode: ${err.response?.statusCode}');
      debugPrint('response:');
      _printLongMessage(err.response?.data?.toString() ?? 'null');
    }
    debugPrint('');
    handler.next(err);
  }

  /// Print long messages by splitting them into chunks
  /// This prevents truncation in Android logs
  void _printLongMessage(String message) {
    if (message.isEmpty) return;

    // Split into chunks of 800 characters (Android logcat limit is ~1024)
    const chunkSize = 800;
    for (int i = 0; i < message.length; i += chunkSize) {
      final end =
          (i + chunkSize < message.length) ? i + chunkSize : message.length;
      debugPrint(message.substring(i, end));
    }
  }
}

class AppClient {
  late AppApi appClient;

  AppClient._() {
    _setupClient();
  }

  AppApi getAppClient() {
    _setupClient();
    return appClient;
  }

  static final AppClient _instance = AppClient._();

  factory AppClient() => _instance;

  void _setupClient() {
    final Dio _dio = Dio();
    // final user_agent = await userAgent();
    _dio
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'User-Agent': 'Mobile'
      };

    // _dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: true,
    //     error: true,
    //     compact: true,
    //     maxWidth: 1000));

    // Add custom logging interceptor to capture all API calls without truncation
    if (kDebugMode) {
      _dio.interceptors.add(FullLogInterceptor());
    }

    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final String? accessToken = appPreference.getData(Const.TOKEN);
      if (!Utils.isEmpty(accessToken)) {
        options.headers["Authorization"] = "Bearer $accessToken";
      }
      // options.headers["Authorization"] =
      // "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkUzRDg1NDU1RjI3QUU5QzgwMjExRTI4NTFFRUNEQkJCIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE2MzcxMjIwNzMsImV4cCI6MTYzNzIwODQ3MywiaXNzIjoiaHR0cDovL2RpYWItaWQtZGV2LnNhdnZ5Y29tLnZuIiwiYXVkIjoiZGlhYmFwaSIsImNsaWVudF9pZCI6IjY3MThFNEYxLTBFQkMtNDYwNy04OTZELURCMEIyN0M4NUYyMyIsInN1YiI6IjAwMDAwMDAwLTAwMDAtMDUwMC0wMDAwLTAwMDAwMDAwMDAwMCIsImF1dGhfdGltZSI6MTYzNzEyMjA3MiwiaWRwIjoibG9jYWwiLCJBc3BOZXQuSWRlbnRpdHkuU2VjdXJpdHlTdGFtcCI6IkpLRE1YNkNENjRaVElSNFYzTUdYU0hWUzNTQTZUU0hNIiwicm9sZSI6IkFkbWluIiwicHJlZmVycmVkX3VzZXJuYW1lIjoicm9vdCIsIm5hbWUiOiJyb290IiwiZW1haWwiOiJjaGlob25nQGNhY3R1cy52biIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaG9uZV9udW1iZXIiOiIrODQ5MDI5MDAxNTgiLCJwaG9uZV9udW1iZXJfdmVyaWZpZWQiOmZhbHNlLCJpc0xpbmtlZEdvb2dsZSI6IkZhbHNlIiwiaXNMaW5rZWRGYWNlYm9vayI6IkZhbHNlIiwiaXNMaW5rZWRBcHBsZSI6IkZhbHNlIiwiaXNNb2JpbGVBY2NvdW50IjoiRmFsc2UiLCJmaXJzdExpbmtlZEFjY291bnQiOiIiLCJqdGkiOiIwOTUwNkEzQjgzMzM1RkJDRTI5QUQ1RTk0OTc5QTYwQSIsInNpZCI6IjNBQzlDNTU0Nzc2N0QyQTk3OTI3RjEyRkZGRjA4ODZBIiwiaWF0IjoxNjM3MTIyMDczLCJzY29wZSI6WyJvcGVuaWQiLCJwcm9maWxlIiwiZW1haWwiLCJwaG9uZSIsImFkZHJlc3MiLCJEaWFCIiwiSWRlbnRpdHlTZXJ2ZXJBcGkiXSwiYW1yIjpbInB3ZCJdfQ.fpxaM8Pu5HPjOeW-_4UFdoQOLguDbIEYqKMK87NSl90wjYFj4IImaEladszrxALpSgyT6LgznJSX0PV3a8BKzU9mBSb3g43dOATDwKFPoPMCSe6Ejuej9ET3nm-bq1-ZUwXmQXVke27QLq3D-6nCki29p294QGD7abvtkyX8RD5P1s_qwoqY5ox9YC__S4NV-lVWdBUjc2OuKHlckTYcPzD-Rze1b2MBjXX-xTPFOo6XqA_3s82LPbFuaL36_HfkkxpU3GG7EdKzR-YAEwh2kJNAQRPMLES3U5-G_Tx2ba4IksiZtT2TF3TucKqnKFyRK6QSAMUxtwQXddVJMqxMpA";
      return handler.next(options);
    }));

    appClient = AppApi(_dio, baseUrl: Utils.getHostUrl());
  }
}
