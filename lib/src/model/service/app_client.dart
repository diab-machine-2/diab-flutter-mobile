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
  late AppApi appClient;

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
        String? accessToken = appPreference.getData(Const.TOKEN);
        if (!Utils.isEmpty(accessToken)) {
          options.headers["Authorization"] = "Bearer $accessToken";
        }
        options.headers["Authorization"] =
        "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkUzRDg1NDU1RjI3QUU5QzgwMjExRTI4NTFFRUNEQkJCIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE2MzMzMzc1OTcsImV4cCI6MTYzMzQyMzk5NywiaXNzIjoiaHR0cDovL2RpYWItaWQtZGV2LnNhdnZ5Y29tLnZuIiwiYXVkIjoiZGlhYmFwaSIsImNsaWVudF9pZCI6IjRBMjkzRTc4LTQ1MTMtNERBRi05NThFLUEwNEY5Mzk3ODMzMiIsInN1YiI6ImY1ZmM2NzZmLTc1NjgtNDcyMC05NDYxLTY5YjMwZjk2NTMzYyIsImF1dGhfdGltZSI6MTYzMzMzNzU5NywiaWRwIjoibG9jYWwiLCJBc3BOZXQuSWRlbnRpdHkuU2VjdXJpdHlTdGFtcCI6IkFENENPNDNXUEk2WjQzMjM3SkhJVTQ1TkU2VzQ0VVBKIiwicm9sZSI6IlVzZXIiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiIrODQzNjM3NTc3NDAiLCJuYW1lIjoiKzg0MzYzNzU3NzQwIiwicGhvbmVfbnVtYmVyIjoiKzg0MzYzNzU3NzQwIiwicGhvbmVfbnVtYmVyX3ZlcmlmaWVkIjp0cnVlLCJpc0xpbmtlZEdvb2dsZSI6IkZhbHNlIiwiaXNMaW5rZWRGYWNlYm9vayI6IkZhbHNlIiwiaXNMaW5rZWRBcHBsZSI6IkZhbHNlIiwiaXNNb2JpbGVBY2NvdW50IjoiVHJ1ZSIsImZpcnN0TGlua2VkQWNjb3VudCI6IiIsImp0aSI6IkEyMUVDNDk3MkYyMjUxOEFFM0MyREFFRkQ4MkNGNUUzIiwiaWF0IjoxNjMzMzM3NTk3LCJzY29wZSI6WyJEaWFCIiwiSWRlbnRpdHlTZXJ2ZXJBcGkiLCJwaG9uZSJdLCJhbXIiOlsicHdkIl19.vyVk_pw1vE5WgB169Ozn1_vqb7WmB7VJV4rXG9RS6x5JoZHj7CqaoxCuAkfyFc27KrlDLF7Ufjc7U9sSs7IS4PabiTUftsu_TXp65I4JyJ5uD_N-xyahNXbwYS5MPGRIpuw5FPe7ZWH81g_kELJSAygRvSW2d0OsyZfv4CrYNvWsP2ZYQCKXNDhwmWDh-FqqJfT9DWaJ3QyarzzVR19o10LmXlPEzj9ta7sUYobsai7V-NFglH0Duw6q8BRZhyWKKOQTjYImq6npbndOmynGS2N87YXgcxB7MOPmaZ3_1JHYm2pR7MHMEAlcUDFHVAb_L17MIK56djWsTaTCrWz_FA";
        return handler.next(options);
      }));
    }
    appClient = AppApi(_dio, baseUrl: Const.HOST_URL);
  }
}

AppApi appClient = AppClient().appClient;
