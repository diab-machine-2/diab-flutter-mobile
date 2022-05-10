import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

class FetchClient {
  static String get identifyBaseURL {
    // return 'is.diab.com.vn';
    //return 'id.savvycom.asia';
    return AppSettings.environment == "staging" ? 'is.savvycom.asia' : 'is.diab.com.vn';
    // return 'diab-id-staging.savvycom.vn';
    // return 'is.stg.diab.cptech.vn';
    // return 'is.dev.diab.cptech.vn';
    // return '139.162.21.142:6001';
  }

  static String get baseURL {
    // return 'api.diab.com.vn';
    // return 'diab-api-staging.savvycom.vn';
    return AppSettings.environment == "staging" ? 'api.savvycom.asia' : 'api.diab.com.vn';
    //return 'api.savvycom.asia';
    // return 'api.stg.diab.cptech.vn';
    // return 'api.mobile.dev.diab.cptech.vn';
    // return '139.162.21.142:6002';
  }

  Future<Options> options() async {
    await checkNetwork();
    final token = await AppSettings.getToken();
    final user_agent = await userAgent();

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
    print(option);
    return option;
  }

  Future<Options> options1() async {
    await checkNetwork();
    final token = await AppSettings.getToken();
    final user_agent = await userAgent();
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
    final user_agent = await userAgent();
    print(token);
    final Options option = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data; boundary=<calculated when request is sent>',
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
    print(option);
    return option;
  }

  Future<Response> fetchData({bool baseIdentify = false, required String url, Map<String, String?>? params}) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    return dio.getUri(Uri.https(domain, url, params), options: option);
  }

  Future<Response> fetchDataNoHeaders(
      {bool baseIdentify = false, required String url, Map<String, String?>? params}) async {
    final option = await options3();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    return dio.getUri(Uri.https(domain, url, params), options: option);
  }

  Future<Response> fetchDataProdNoHeaders(
      {bool baseIdentify = false, required String url, Map<String, String?>? params}) async {
    final option = await options3();
    final domain = "api.diab.com.vn";
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
    return dio.postUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
  }

  Future<Response> postUri(
      {bool baseIdentify = false, bool baseOption = false, required String url, Map<String, dynamic>? params}) async {
    final Options option = baseOption ? await options() : await options1();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    return dio.postUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
  }

  Future<http.StreamedResponse> postHttp(
      {bool baseIdentify = false, required String path, required dynamic params, List<String>? files}) async {
    final token = await AppSettings.getToken();
    final user_agent = await userAgent();
    final headers = {'Authorization': 'Bearer $token', 'User-Agent': 'Mobile'};
    final request =
        http.MultipartRequest('POST', Uri.parse('https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
    request.fields.addAll(params);

    for (final file in files ?? []) {
      final value = await http.MultipartFile.fromPath('images', file);
      request.files.add(value);
    }

    request.headers.addAll(headers);

    return request.send();
  }

  Future<http.StreamedResponse> postHttp2(
      {bool baseIdentify = false, required String path, required dynamic params}) async {
    final token = await AppSettings.getToken();
    final user_agent = await userAgent();
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'User-Agent': 'Mobile'};
    final request = http.Request('POST', Uri.parse('https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
    request.body = params;
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
    final user_agent = await userAgent();
    final headers = {'Authorization': 'Bearer $token', 'User-Agent': 'Mobile'};
    final request =
        http.MultipartRequest('PUT', Uri.parse('https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
    request.fields.addAll(params);

    for (final file in files) {
      final value = await http.MultipartFile.fromPath(fileName ?? 'images', file);
      request.files.add(value);
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<Response> putData({bool baseIdentify = false, required String url, Map<String, dynamic>? params}) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    return dio.putUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
  }

  Future<Response> delete({bool baseIdentify = false, required String url, Map<String, dynamic>? params}) async {
    final option = await options();
    final domain = baseIdentify ? identifyBaseURL : baseURL;
    final Dio dio = Dio();
    logRequest(dio);
    return dio.deleteUri(
        Uri.https(
          domain,
          url,
        ),
        data: params,
        options: option);
  }

  logRequest(Dio dio) {
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true, requestBody: true, responseBody: true, responseHeader: true, compact: true, error: true));
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

// class FetchClient {
//   static String get identifyBaseURL {
//     return 'is.diab.com.vn';
//     // return 'is.stg.diab.cptech.vn';
//     // return 'is.dev.diab.cptech.vn';
//     // return '139.162.21.142:6001';
//   }

//   static String get baseURL {
//     return 'api.diab.com.vn';
//     // return 'api.stg.diab.cptech.vn';
//     // return 'api.mobile.dev.diab.cptech.vn';
//     // return '139.162.21.142:6002';
//   }

//   Future<Options> options() async {
//     await checkNetwork();
//     final token = await AppSettings.getToken();

//     var option = Options(
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json; charset=UTF-8'
//         },
//         followRedirects: false,
//         validateStatus: (status) {
//           return true; //status < 500;
//         });
//     print(option);
//     return option;
//   }

//   Future<Options> options1() async {
//     await checkNetwork();
//     final token = await AppSettings.getToken();
//     var option = Options(
//         contentType: "application/x-www-form-urlencoded",
//         headers: {
//           'Authorization': token,
//         },
//         followRedirects: false,
//         validateStatus: (status) {
//           return true; //status < 500;
//         });
//     return option;
//   }

//   Future<Options> options2() async {
//     await checkNetwork();
//     final token = await AppSettings.getToken();
//     print(token);
//     var option = Options(
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type':
//               'multipart/form-data; boundary=<calculated when request is sent>',
//         },
//         followRedirects: false,
//         validateStatus: (status) {
//           return true; //status < 500;
//         });
//     return option;
//   }

//   Future<Response> fetchData(
//       {bool baseIdentify = false,
//       required String url,
//       Map<String, String?>? params}) async {
//     final option = await options();
//     final domain = baseIdentify ? identifyBaseURL : baseURL;
//     Dio dio = Dio();
//     logRequest(dio);
//     return await dio.getUri(Uri.https(domain, url, params), options: option);
//   }

//   Future<Response> postData({
//     bool baseIdentify = false,
//     required String url,
//     FormData? params,
//     bool baseOption = false,
//   }) async {
//     final option = await options2();
//     final domain = baseIdentify ? identifyBaseURL : baseURL;
//     Dio dio = Dio();
//     logRequest(dio);
//     return await dio.postUri(
//         Uri.https(
//           domain,
//           url,
//         ),
//         data: params,
//         options: option);
//   }

//   Future<Response> postUri(
//       {bool baseIdentify = false,
//       bool baseOption = false,
//       required String url,
//       Map<String, dynamic>? params}) async {
//     final option = baseOption ? await options() : await options1();
//     final domain = baseIdentify ? identifyBaseURL : baseURL;
//     Dio dio = Dio();
//     logRequest(dio);
//     return await dio.postUri(
//         Uri.https(
//           domain,
//           url,
//         ),
//         data: params,
//         options: option);
//   }

//   Future<http.StreamedResponse> postHttp(
//       {bool baseIdentify = false,
//       required String path,
//       required dynamic params, List<String>? files}) async {
//     final token = await AppSettings.getToken();
//     var headers = {'Authorization': 'Bearer $token'};
//     var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             'https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
//     request.fields.addAll(params);

//     for (var file in files ?? []) {
//       final value = await http.MultipartFile.fromPath('images', file);
//       request.files.add(value);
//     }

//     request.headers.addAll(headers);

//     return await request.send();
//   }

//   Future<http.StreamedResponse> postHttp2(
//       {bool baseIdentify = false, required String path, required dynamic params}) async {
//     final token = await AppSettings.getToken();
//     var headers = {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json'
//     };
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
//     request.body = params;
//     request.headers.addAll(headers);

//     return await request.send();
//   }

//   Future<http.StreamedResponse> putHttp(
//       {bool baseIdentify = false,
//       required String path,
//       required dynamic params,
//       required List<String> files,
//       String? fileName}) async {
//     final token = await AppSettings.getToken();
//     var headers = {'Authorization': 'Bearer $token'};
//     var request = http.MultipartRequest(
//         'PUT',
//         Uri.parse(
//             'https://' + (baseIdentify ? identifyBaseURL : baseURL) + path));
//     request.fields.addAll(params);

//     for (var file in files) {
//       final value = await http.MultipartFile.fromPath(
//           fileName == null ? 'images' : fileName, file);
//       request.files.add(value);
//     }

//     request.headers.addAll(headers);

//     return await request.send();
//   }

//   Future<Response> putData(
//       {bool baseIdentify = false,
//       required String url,
//       Map<String, dynamic>? params}) async {
//     final option = await options();
//     final domain = baseIdentify ? identifyBaseURL : baseURL;
//     Dio dio = Dio();
//     logRequest(dio);
//     return await dio.putUri(
//         Uri.https(
//           domain,
//           url,
//         ),
//         data: params,
//         options: option);
//   }

//   Future<Response> delete(
//       {bool baseIdentify = false,
//       required String url,
//       Map<String, dynamic>? params}) async {
//     final option = await options();
//     final domain = baseIdentify ? identifyBaseURL : baseURL;
//     Dio dio = Dio();
//     logRequest(dio);
//     return await dio.deleteUri(
//         Uri.https(
//           domain,
//           url,
//         ),
//         data: params,
//         options: option);
//   }

//   logRequest(Dio dio) {
//     dio.interceptors.add(PrettyDioLogger(
//       requestHeader: true,
//       requestBody: true,
//       responseBody: true,
//       responseHeader: true,
//       compact: true,
//       error: true
//     ));
//   }

//   checkNetwork() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         print('connected');
//       }
//     } on SocketException catch (_) {
//       throw R.string.error_can_not_connect_to_server.tr();
//     }
//   }

//   Future<bool> hasNetwork() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return true;
//       } else {
//         return false;
//       }
//     } on SocketException catch (_) {
//       return false;
//     }
//   }
// }