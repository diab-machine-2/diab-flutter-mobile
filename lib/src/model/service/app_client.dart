import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/logger.dart';
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
      "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkUzRDg1NDU1RjI3QUU5QzgwMjExRTI4NTFFRUNEQkJCIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE2MzUyMzc0MDksImV4cCI6MTYzNTMyMzgwOSwiaXNzIjoiaHR0cDovL2RpYWItaWQtZGV2LnNhdnZ5Y29tLnZuIiwiYXVkIjoiZGlhYmFwaSIsImNsaWVudF9pZCI6IjRBMjkzRTc4LTQ1MTMtNERBRi05NThFLUEwNEY5Mzk3ODMzMiIsInN1YiI6ImY1ZmM2NzZmLTc1NjgtNDcyMC05NDYxLTY5YjMwZjk2NTMzYyIsImF1dGhfdGltZSI6MTYzNTIzNzQwOSwiaWRwIjoibG9jYWwiLCJBc3BOZXQuSWRlbnRpdHkuU2VjdXJpdHlTdGFtcCI6IkFENENPNDNXUEk2WjQzMjM3SkhJVTQ1TkU2VzQ0VVBKIiwicm9sZSI6IlVzZXIiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiIrODQzNjM3NTc3NDAiLCJuYW1lIjoiKzg0MzYzNzU3NzQwIiwicGhvbmVfbnVtYmVyIjoiKzg0MzYzNzU3NzQwIiwicGhvbmVfbnVtYmVyX3ZlcmlmaWVkIjp0cnVlLCJpc0xpbmtlZEdvb2dsZSI6IkZhbHNlIiwiaXNMaW5rZWRGYWNlYm9vayI6IkZhbHNlIiwiaXNMaW5rZWRBcHBsZSI6IkZhbHNlIiwiaXNNb2JpbGVBY2NvdW50IjoiVHJ1ZSIsImZpcnN0TGlua2VkQWNjb3VudCI6IiIsImp0aSI6IkFEODg2OTMwRTQ5N0U4Q0VDOEEyQTcxNDVFMjY5NkY1IiwiaWF0IjoxNjM1MjM3NDA5LCJzY29wZSI6WyJEaWFCIiwiSWRlbnRpdHlTZXJ2ZXJBcGkiLCJwaG9uZSJdLCJhbXIiOlsicHdkIl19.oBq5_6OyXqODXKNBl9GH8VYU5A4F6j74-7sSOpFz0yNBbNZhfwamSKofCC2OVBxHc02Yv7lAEAEkLILE7qvat6-V6HnnRDAY98VGse3G1WxAD-bkA1zNyEqRTIf968bY5YUF2Hng-b78K8cCTIUSbmDU4s2r0WKJXVMXhappuWcdi_VFgz3Cx_V6TJsRJXnpl-4sI-qAdAs5BITWIHGXpo-I6uQhY8UU981TD60f0HSBK-uwdcr2468x9ATn3qM13Ev3K_oA0SVW71cwv0k2Pci_OBvNBRwABO0stQ3NO39EMakU0oAkHIAuOJ2s15_QSVVsuGPPVFWT8kmvHH6TiQ";
      return handler.next(options);
    }));
    appClient = AppApi(_dio, baseUrl: Const.HOST_URL);
  }
}

AppApi appClient = AppClient().appClient;
