import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';

class ApiMethods {
  static final Map<String, String> _headers = {
    // "content-type": "application/json",
    "Content-Type": "application/json; charset=utf-8"
  };
  static String get baseURL {
    return AppSettings.environment == "staging"
        ? Const.DOMAIN_STAGING
        : Const.DOMAIN;
  }

  static Future<http.Response> get({
    required String path,
    Map<String, dynamic>? data,
  }) async {
    String pathUri = 'https://' + (baseURL) + path + "?";
    if (data != null && data.isNotEmpty) {
      data.forEach((key, value) {
        pathUri += '&$key=$value';
      });
    }
    pathUri = pathUri.replaceFirst("?&", "?");
    final token = await AppSettings.getToken();
    

    _headers.addAll({'Authorization': 'Bearer $token'});

    http.Response response =
        await http.get(Uri.parse(pathUri), headers: _headers);

    return response;
  }

  static delete({
    required String apiUrl,
  }) async {
    final token = await AppSettings.getToken();
    print("apiUrl DELETE: $apiUrl");

    http.Response response;
    response = await http.delete(Uri.parse(apiUrl), headers: _headers);
    var dataResult = jsonDecode(response.body);
    return dataResult;
  }

  static Future<http.Response> post({
    dynamic data,
    required String path,
    bool hasToken = true,
  }) async {
    Uri pathUri = Uri.parse('https://' + (baseURL) + path);
    if (hasToken) {
      final token = await AppSettings.getToken();
      _headers.addAll({'Authorization': 'Bearer $token'});
    }
    print("apiUrl POST: $pathUri");

    // try {
    http.Response response = await http.post(
      pathUri,
      body: json.encode(data),
      headers: _headers,
    );

    return response;
    // } catch (e) {
    //   print("Server Error $apiUrl: $e");
    //   return null;
    // }
  }

  static Future<Map<String, dynamic>?> put({
    Map<String, dynamic>? data,
    required String apiUrl,
    bool hasToken = true,
  }) async {
    if (hasToken) {
      final token = await AppSettings.getToken();
      _headers.addAll({'Authorization': 'Bearer $token'});
    }
    print("apiUrl PUT: $apiUrl");
    try {
      http.Response response;
      data = data;
      response = await http.put(
        Uri.parse(apiUrl),
        body: data != null ? json.encode(data) : "",
        headers: _headers,
      );
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      print("Server Error $apiUrl: $e");
      return null;
    }
  }
}
