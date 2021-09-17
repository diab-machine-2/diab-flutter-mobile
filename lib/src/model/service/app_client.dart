import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../app_api.dart';

const _defaultConnectTimeout = Duration.millisecondsPerMinute;
const _defaultReceiveTimeout = Duration.millisecondsPerMinute;

class AppClient {
  AppApi appClient;

  AppClient._privateConstructor() {
    _setupClient();
  }

  static final AppClient _instance = AppClient._privateConstructor();

  factory AppClient() {
    return _instance;
  }

  void _setupClient() {
    Dio _dio = Dio();
    _dio
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout
      ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};

    if (kDebugMode) {
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
        String accessToken = appPreference.getData(Const.TOKEN);
        if (!Utils.isEmpty(accessToken)) {
          options.headers["Authorization"] = "Bearer $accessToken";
        }
        return handler.next(options);
      }));
    }
    appClient = AppApi(_dio, baseUrl: Const.HOST_URL);
  }
}

AppApi appClient = AppClient().appClient;
