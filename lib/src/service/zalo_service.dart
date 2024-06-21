import 'dart:convert';

import 'package:zalo_flutter/zalo_flutter.dart';

class ZaloService {
  Future<ZaloLoginResult> login() async {
    // TODO: Just take the key, remove after GOTTEN
    // if (Platform.isAndroid) {
    //   final String? hashKey = await ZaloFlutter.getHashKeyAndroid();
    //   print('HashKey: $hashKey');
    // }

    // set timeout for login
    ZaloFlutter.setTimeout(Duration(hours: 2));

    // do login
    final Map<dynamic, dynamic>? data = await ZaloFlutter.login(
      refreshToken: null,
      // externalInfo: {},
    );

    // handle login result >> nothing received
    if (data == null) {
      throw ZaloLoginBackException();
    }

    if (data['isSuccess'] == true || data['is_success'] == true) {
      final accessToken = data['data'] != null
          ? (data['data']['access_token'] ?? data['data']['accessToken'])
          : null;

      if (accessToken == null) {
        throw ZaloLoginException('Login success but with no access token');
      }

      // retry to get profile
      int tryCount = 1;
      int maxRetry = 3;
      Duration retryWait = Duration(milliseconds: 300);
      Map<dynamic, dynamic>? profile = await ZaloFlutter.getUserProfile(accessToken: accessToken);
      while (profile == null && tryCount < maxRetry) {
        await Future.delayed(retryWait);
        profile = await ZaloFlutter.getUserProfile(accessToken: accessToken);
        tryCount++;
      }

      // exhausted retry
      if (profile == null || profile["data"] == null) {
        String moreInfo = profile == null ? 'null' : jsonEncode(profile);
        throw ZaloLoginException('Login success but failed to get profile\nInfo: $moreInfo');
      }

      // look good
      return ZaloLoginResult.fromJson(data['data'], profile["data"]);
    } else {
      String moreInfo = jsonEncode(data);
      throw ZaloLoginException('Login failed\nInfo: $moreInfo');
    }
  }
}

class ZaloLoginResult {
  String accessToken;
  String refreshToken;
  // int? expiresIn;
  // int? refreshTokenExpiresIn;
  String id;
  String name;

  ZaloLoginResult({
    required this.accessToken,
    required this.refreshToken,
    // this.expiresIn,
    // this.refreshTokenExpiresIn,
    required this.id,
    required this.name,
  });

  factory ZaloLoginResult.fromJson(Map<dynamic, dynamic> json, Map<dynamic, dynamic> profile) {
    return ZaloLoginResult(
        accessToken: json['access_token'] ?? json['accessToken'],
        refreshToken: json['refresh_token'] ?? json['refreshToken'],
        // expiresIn: json['expires_in'] != null ? int.tryParse(json['expires_in'].toString()) : null,
        // refreshTokenExpiresIn: json['refresh_token_expires_in'] != null
        //     ? int.tryParse(json['refresh_token_expires_in'].toString())
        //     : null,
        id: profile['id'],
        name: profile['name']);
  }
}

class ZaloLoginException implements Exception {
  final String message;
  ZaloLoginException(this.message);
}

class ZaloLoginEmptyException extends ZaloLoginException {
  ZaloLoginEmptyException(String message) : super(message);
}

class ZaloLoginBackException extends ZaloLoginException {
  ZaloLoginBackException() : super("");
}
