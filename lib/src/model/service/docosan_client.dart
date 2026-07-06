import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';

import 'app_client.dart' show FullLogInterceptor;
import '../docosan_api.dart';

const _defaultConnectTimeout = Duration(minutes: 1);
const _defaultReceiveTimeout = Duration(minutes: 1);

class DocosanClient {
  late DocosanApi docosanClient;
  late Dio dio;

  DocosanClient._() {
    _setupClient();
  }

  DocosanApi getDocosanClient() {
    _setupClient();
    return docosanClient;
  }

  static final DocosanClient _instance = DocosanClient._();

  factory DocosanClient() => _instance;

  void _setupClient() {
    final Dio _dio = Dio();
    dio = _dio;
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

    if (kDebugMode) {
      _dio.interceptors.add(FullLogInterceptor(tag: 'DOCOSAN API'));
    }

    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final String? accessToken = appPreference.getData(Const.DOCOSAN_TOKEN);
      if (!Utils.isEmpty(accessToken)) {
        options.headers["Authorization"] = "Bearer $accessToken";
      }

      options.headers["x-api-key"] = Utils.getOrganizationApiKey();
      return handler.next(options);
    }));

    docosanClient = DocosanApi(_dio, baseUrl: Utils.getHostDocosanUrl());
  }
}
