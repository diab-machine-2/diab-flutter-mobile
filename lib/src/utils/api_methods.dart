import 'dart:convert';
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:dartz/dartz_streaming.dart';
import 'package:http/http.dart' as http;
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:http_parser/http_parser.dart';

class ApiMethods {
  static final Map<String, String> _headers = {
    // "content-type": "application/json",
    "Content-Type": "application/json; charset=utf-8"
  };
  static String get baseURL {
    if (AppSettings.environment == "staging") {
      return Const.DOMAIN_STAGING;
    } else if (AppSettings.environment == "dev") {
      return Const.DOMAIN_DEV;
    } else {
      return Const.DOMAIN;
    }
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
    Uri pathUri = Uri.parse('https://' + (baseURL) + apiUrl);

    http.Response response;
    response = await http.delete(pathUri, headers: _headers);
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

  static Future<Map<String, dynamic>?> postFile(
      Uint8List bytes, Uint8List? fullImage, String apiUrl,
      {int retry = 0}) async {
    if (retry > 1) {
      return null;
    }
    final token = await AppSettings.getToken();
    _headers.addAll({'Authorization': 'Bearer $token'});
    print("apiUrl POST: $apiUrl");
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll(_headers);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // Name of the field where you want to send the file
          bytes,
          filename: 'image.jpg', // Filename for the file
          contentType: MediaType('image', 'jpeg'), // Content type of the file
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        // If you expect JSON response, you can decode it here
        var responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        if (fullImage != null)
          return postFile(fullImage, fullImage, apiUrl, retry: retry + 1);
        else
          return null;
      }
    } catch (e) {
      BotToast.showLoading();
      // if error retry with full image
      print("Server Error $apiUrl: $e");
      if (fullImage != null)
        return postFile(fullImage, fullImage, apiUrl, retry: retry + 1);
      else
        return null;
    }
  }
}
