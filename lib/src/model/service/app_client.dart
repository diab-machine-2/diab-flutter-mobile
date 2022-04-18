import 'package:dio/dio.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

import '../app_api.dart';

const _defaultConnectTimeout = Duration.millisecondsPerMinute;
const _defaultReceiveTimeout = Duration.millisecondsPerMinute;

class AppClient {
  late AppApi appClient;

  AppClient._privateConstructor() {
    _setupClient();
  }

  static final AppClient _instance = AppClient._privateConstructor();

  factory AppClient() {
    return _instance;
  }

  Future<void> _setupClient() async {
    final Dio _dio = Dio();
    // final user_agent = await userAgent();
    _dio
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'User-Agent': 'Mobile'
      };

    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 1000));

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

AppApi appClient = AppClient().appClient;
