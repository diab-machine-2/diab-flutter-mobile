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
      // options.headers["Authorization"] = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkUzRDg1NDU1RjI3QUU5QzgwMjExRTI4NTFFRUNEQkJCIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE2MzM0MDYyNzgsImV4cCI6MTYzMzQ5MjY3OCwiaXNzIjoiaHR0cDovL2RpYWItaWQtZGV2LnNhdnZ5Y29tLnZuIiwiYXVkIjoiZGlhYmFwaSIsImNsaWVudF9pZCI6IjRBMjkzRTc4LTQ1MTMtNERBRi05NThFLUEwNEY5Mzk3ODMzMiIsInN1YiI6ImY1ZmM2NzZmLTc1NjgtNDcyMC05NDYxLTY5YjMwZjk2NTMzYyIsImF1dGhfdGltZSI6MTYzMzQwNjI3OCwiaWRwIjoibG9jYWwiLCJBc3BOZXQuSWRlbnRpdHkuU2VjdXJpdHlTdGFtcCI6IkFENENPNDNXUEk2WjQzMjM3SkhJVTQ1TkU2VzQ0VVBKIiwicm9sZSI6IlVzZXIiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiIrODQzNjM3NTc3NDAiLCJuYW1lIjoiKzg0MzYzNzU3NzQwIiwicGhvbmVfbnVtYmVyIjoiKzg0MzYzNzU3NzQwIiwicGhvbmVfbnVtYmVyX3ZlcmlmaWVkIjp0cnVlLCJpc0xpbmtlZEdvb2dsZSI6IkZhbHNlIiwiaXNMaW5rZWRGYWNlYm9vayI6IkZhbHNlIiwiaXNMaW5rZWRBcHBsZSI6IkZhbHNlIiwiaXNNb2JpbGVBY2NvdW50IjoiVHJ1ZSIsImZpcnN0TGlua2VkQWNjb3VudCI6IiIsImp0aSI6IkE1MDRCMTgwMEUwNkJFQTA3RTU5QkRFRDFDMEQyNDYxIiwiaWF0IjoxNjMzNDA2Mjc4LCJzY29wZSI6WyJEaWFCIiwiSWRlbnRpdHlTZXJ2ZXJBcGkiLCJwaG9uZSJdLCJhbXIiOlsicHdkIl19.ol8q4fuepgETBc3k9VFx6Y--mVhMZBWejCgH6GE2stivnOOgPqQpsRA0xmV47FLXYED-ObY7-QO9Y783_OtPGfANfBAkOG7a2B-fQG7GWXo7FSWcUvuwsFf9gVWnmy0HHnAif02JHp8ZBOpQJP4F4bpSYgidTToQwgtMP7_EzDnRJUTE1Y4yolTw0B42AKm_fge_2coR4iOEdafEW27L1R5OdkVfW0hBTHwF5KGHsZuk_b_CN-KjRv7r5uljfeo88TJhHAJEBcFQMOxTB4TgpRLhLoFZec1SmhnNi6Ct9IHIh_Sz3y3R8UnoKCSY6RFAkdiwV5ip1qiOAdDArD31ww";
      return handler.next(options);
    }));
    appClient = AppApi(_dio, baseUrl: Const.HOST_URL);
  }
}

AppApi appClient = AppClient().appClient;
