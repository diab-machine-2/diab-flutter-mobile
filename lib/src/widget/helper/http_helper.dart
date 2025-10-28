import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';

class FetchClient {
  static String get identifyBaseURL {
    // return 'is.diab.com.vn';
    //return 'id.savvycom.asia';
    if (AppSettings.environment == "staging") {
      return Const.IS_DOMAIN_STAGING;
    } else if (AppSettings.environment == "dev") {
      return Const.IS_DOMAIN_DEV;
    } else {
      return Const.IS_DOMAIN;
    }
    // return 'diab-id-staging.savvycom.vn';
    // return 'is.stg.diab.cptech.vn';
    // return 'is.dev.diab.cptech.vn';
    // return '139.162.21.142:6001';
  }

  static String get baseURL {
    // return 'api.diab.com.vn';
    // return 'diab-api-staging.savvycom.vn';
    if (AppSettings.environment == "staging") {
      return Const.DOMAIN_STAGING;
    } else if (AppSettings.environment == "dev") {
      return Const.DOMAIN_DEV;
    } else {
      return Const.DOMAIN;
    }
    //return 'api.savvycom.asia';
    // return 'api.stg.diab.cptech.vn';
    // return 'api.mobile.dev.diab.cptech.vn';
    // return '139.162.21.142:6002';
  }

  static String get docosanBaseUrl {
    // return 'https://api.docosan.com/';
    // return 'https://api.staging.docosan.com/';
    if (AppSettings.environment == "product") {
      return Const.HOST_DOCOSAN_URL;
    } else {
      return Const.HOST_DOCOSAN_URL_STAGING;
    }
  }

  Future<Options> options() async {
    await checkNetwork();
    final token = await AppSettings.getToken();

    // final userAgent = await userAgent();

    final Options option = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          'User-Agent': 'Mobile',
        },
        followRedirects: false,
        validateStatus: (status) {
          return true; //status < 500;
        });
    // print(option);
    return option;
  }

  Future<Options> options1() async {
    await checkNetwork();
    final token = await AppSettings.getToken();
    // final userAgent = await userAgent();
    final Options option = Options(
        contentType: "application/x-www-form-urlencoded",
        headers: {
          'Authorization': token,
          'User-Agent': 'Mobile',
        },
        followRedirects: false,
        validateStatus: (status) {
          return true; //status < 500;
        });
    return option;
  }

  Future<Options> options2() async {
    await checkNetwork();
    final token = await AppSettings.getToken();
    // final userAgent = await userAgent();
    // print(token);
    final Options option = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':
              'multipart/form-data; boundary=<calculated when request is sent>',
          'User-Agent': 'Mobile',
        },
        followRedirects: false,
        validateStatus: (status) {
          return true; //status < 500;
        });
    return option;
  }

  Future<Options> options3() async {
    await checkNetwork();
    final Options option = Options(
        // headers: {
        //   'Authorization': 'Bearer $token',
        //   'Content-Type': 'application/json; charset=UTF-8',
        //   'User-Agent': 'Mobile',
        // },
        followRedirects: false,
        validateStatus: (status) {
          return true; //status < 500;
        });
    // print(option);
    return option;
  }

  Future<Response> fetchData({
    bool baseIdentify = false,
    required String url,
    Map<String, String?>? params,
  }) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);

    Uri uri = Uri.https(domain, url, params);

    Response response = await dio.getUri(uri, options: option);
    Console.logJson('GET', url);
    // final token = await AppSettings.getToken();
    // Console.logJson('token', token);
    Console.logJson('Request', params);
    Console.log('response', response.statusCode);
    return response;
  }

  Future<Response> fetchDataNoHeaders(
      {bool baseIdentify = false,
      required String url,
      Map<String, String?>? params}) async {
    final option = await options3();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    Response response =
        await dio.getUri(Uri.https(domain, url, params), options: option);
    return response;
  }

  Future<Response> fetchDataProdNoHeaders(
      {bool baseIdentify = false,
      required String url,
      Map<String, String?>? params}) async {
    final option = await options3();
    final domain = Const.DOMAIN;
    final Dio dio = Dio();
    logRequest(dio);
    return dio.getUri(Uri.https(domain, url, params), options: option);
  }

  Future<Response> postData({
    bool baseIdentify = false,
    required String url,
    FormData? params,
    bool baseOption = false,
  }) async {
    final option = await options2();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    Response response = await dio.postUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
    Console.logJson('POST', url);
    Console.log('response', response.statusCode);
    return response;
  }

  Future<Response> postUri({
    bool baseIdentify = false,
    bool baseOption = false,
    required String url,
    Map<String, dynamic>? params,
  }) async {
    final Options option = baseOption ? await options() : await options1();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    Response response = await dio.postUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
    Console.logJson('API', url);
    Console.logJson('Request', params);
    Console.log('response', response.statusCode);
    return response;
  }

  Future<http.StreamedResponse> postHttp(
      {bool baseIdentify = false,
      required String path,
      required dynamic params,
      List<String>? files}) async {
    final token = await AppSettings.getToken();
    // final userAgent = await userAgent();
    final headers = {'Authorization': 'Bearer $token', 'User-Agent': 'Mobile'};
    Uri uri = Uri.parse(
        'https://' + (baseIdentify ? identifyBaseURL : baseURL) + path);
    final request = http.MultipartRequest('POST', uri);
    request.fields.addAll(params);
    Console.log('token', token);
    Console.log('uri', uri);
    Console.logJson('Request', params);

    for (final file in files ?? []) {
      final value = await http.MultipartFile.fromPath('images', file, contentType: MediaType('image', 'jpeg'));
      request.files.add(value);
    }

    request.headers.addAll(headers);

    return request.send();
  }

  Future<http.StreamedResponse> postHttp2(
      {bool baseIdentify = false,
      required String path,
      required dynamic params}) async {
    final token = await AppSettings.getToken();
    // final userAgent = await userAgent();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'User-Agent': 'Mobile'
    };
    final request = http.Request(
        'POST',
        Uri.parse(
            'https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
    request.body = params;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    Console.logJson('POST', path);
    Console.logJson('Request', params);

    return response;
  }

  Future<http.StreamedResponse> postHttp3({
    required String path,
    required Map<String, String> params,
    Uint8List? bytes,
    String? fileName,
  }) async {
    // final token = await AppSettings.getDocosanToken();
    // final userAgent = await userAgent();
    final headers = {
      // 'Authorization': 'Bearer $token',
      'User-Agent': 'Mobile',
    };
    Uri uri = Uri.parse(docosanBaseUrl + path);
    final request = http.MultipartRequest('POST', uri);
    request.fields.addAll(params);
    // Console.log('token', token);
    Console.log('uri', uri);
    // Console.logJson('Request', params);

    if (bytes != null && bytes.isNotEmpty) {
      final value =
          http.MultipartFile.fromBytes('file', bytes, filename: fileName);
      request.files.add(value);
    }

    request.headers.addAll(headers);

    return request.send();
  }

  Future<http.StreamedResponse> putHttp(
      {bool baseIdentify = false,
      required String path,
      required dynamic params,
      required List<String> files,
      String? fileName}) async {
    final token = await AppSettings.getToken();
    final headers = {'Authorization': 'Bearer $token', 'User-Agent': 'Mobile'};
    final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
    request.fields.addAll(params);

    for (final file in files) {
      final value =
          await http.MultipartFile.fromPath(fileName ?? 'images', file);
      request.files.add(value);
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<Response> putData(
      {bool baseIdentify = false,
      required String url,
      Map<String, dynamic>? params}) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    Console.logJson('API', url);
    Console.logJson('Request', params);
    Response response = await dio.putUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
    return response;
  }

  Future<Response> putData2({
    bool baseIdentify = false,
    required String url,
    FormData? params,
  }) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    Response response = await dio.putUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
    return response;
  }

  Future<Response> delete(
      {bool baseIdentify = false,
      required String url,
      Map<String, dynamic>? params}) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    Response response = await dio.deleteUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);

    return response;
  }

  logRequest(Dio dio) {
    // PrettyDioLogger dioLog = PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: true,
    //     compact: true,
    //     error: true,
    //     logPrint: (object) {});
    // dio.interceptors.add(dioLog);
    // dio.interceptors.add(LogInterceptor(request: true, responseBody: false));
    // dio.interceptors.add(TrackingInterceptor());
  }

  checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
}

class TrackingInterceptor extends Interceptor {
  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401) {
      final token = await AppSettings.getToken();
      UserModel? userInfo = AppSettings.userInfo;
      Map<String, dynamic> errorData = {
        'bearerToken': token,
        'phone': userInfo?.phoneNumber,
        'url': response.requestOptions.path,
        'requestOptions': response.requestOptions.data.toString(),
        'responseData': response.data,
      };

      final Options option = await FetchClient().options();
      final domain = FetchClient.baseURL;
      final Dio dio = Dio();
      await dio.postUri(Uri.https(domain, '/App/Logs'),
          data: {'content': jsonEncode(errorData)}, options: option);
    }
    handler.next(response);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final token = await AppSettings.getToken();
      UserModel? userInfo = AppSettings.userInfo;

      Map<String, dynamic> errorData = {
        'phone': userInfo?.phoneNumber,
        'bearerToken': token,
        'url': err.response?.requestOptions.path,
        'requestOptions': err.response?.requestOptions.data.toString(),
        'responseData': err.response?.data,
        'err': err,
      };

      final Options option = await FetchClient().options();
      final domain = FetchClient.baseURL;
      final Dio dio = Dio();
      await dio.postUri(Uri.https(domain, '/App/Logs'),
          data: {'content': jsonEncode(errorData)}, options: option);
    }
    handler.next(err);
  }
}
