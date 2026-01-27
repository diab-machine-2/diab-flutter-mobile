import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';

import '../app_api.dart';

const _defaultConnectTimeout = Duration(minutes: 1);
const _defaultReceiveTimeout = Duration(minutes: 1);

/// Custom logging interceptor that handles long responses without truncation.
/// [tag] is prefixed to every log line (e.g. 'APP API' or 'DOCOSAN API') for easy filtering.
class FullLogInterceptor extends Interceptor {
  FullLogInterceptor({required this.tag});

  final String tag;

  void _log(String message) => debugPrint('[$tag] $message');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('*** Request ***');
    _log('uri: ${options.uri}');
    _log('method: ${options.method}');
    _log('responseType: ${options.responseType}');
    _log('followRedirects: ${options.followRedirects}');
    _log('connectTimeout: ${options.connectTimeout}');
    _log('sendTimeout: ${options.sendTimeout}');
    _log('receiveTimeout: ${options.receiveTimeout}');
    _log('receiveDataWhenStatusError: ${options.receiveDataWhenStatusError}');
    _log('extra: ${options.extra}');
    _log('headers:');
    options.headers.forEach((key, value) {
      _log(' $key: $value');
    });
    _log('data:');
    if (options.data != null) {
      _printLongMessage(options.data.toString());
    } else {
      _log('null');
    }
    _log('');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('*** Response ***');
    _log('uri: ${response.requestOptions.uri}');
    _log('statusCode: ${response.statusCode}');
    _log('headers:');
    response.headers.forEach((key, values) {
      _log(' $key: ${values.join(', ')}');
    });
    // _log('Response Text:');
    // if (response.data != null) {
    //   String responseText;
    //   if (response.data is String) {
    //     responseText = response.data;
    //   } else {
    //     // Pretty print JSON
    //     try {
    //       responseText =
    //           const JsonEncoder.withIndent('  ').convert(response.data);
    //     } catch (e) {
    //       responseText = response.data.toString();
    //     }
    //   }
    //   _printLongMessage(responseText);
    // } else {
    //   _log('null');
    // }
    _log('');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('*** Error ***');
    _log('uri: ${err.requestOptions.uri}');
    _log('error: ${err.error}');
    _log('type: ${err.type}');
    if (err.response != null) {
      _log('statusCode: ${err.response?.statusCode}');
      _log('response:');
      _printLongMessage(err.response?.data?.toString() ?? 'null');
    }
    _log('');
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
      _log(message.substring(i, end));
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
      _dio.interceptors.add(FullLogInterceptor(tag: 'APP API'));
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
