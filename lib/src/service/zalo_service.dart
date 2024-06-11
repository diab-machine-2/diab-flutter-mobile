import 'dart:convert';

import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:zalo_flutter/zalo_flutter.dart';

class ZaloService {
  Future<ZaloLoginResult> login() async {
    // TODO: Just take the key, remove after GOTTEN
    // if (Platform.isAndroid) {
    //   final String? hashKey = await ZaloFlutter.getHashKeyAndroid();
    //   print('HashKey: $hashKey');
    // }
    ZaloFlutter.setTimeout(Duration(hours: 2));
    final Map<dynamic, dynamic>? data = await ZaloFlutter.login(
      refreshToken: null,
      // externalInfo: {},
    );
    try {
      if (data != null && (data['isSuccess'] == true || data['is_success'] == true)) {
        final accessToken =
            data['data']['access_token'] ?? data['data']['accessToken'];
        final profile =
            await ZaloFlutter.getUserProfile(accessToken: accessToken);
        if (profile != null && profile["data"] != null) {
          return ZaloLoginResult.fromJson(data['data'], profile["data"]);
        }
      } else if (data != null && data['data'] != null) {
        TrackingManager.recordError(new Exception(jsonEncode(data)), null);
        throw ZaloLoginException(
            data['data']['message']?.toString() ?? 'Login failed');
      } else {
        throw ZaloLoginException('Login failed');
      }
    } catch (e, s) {
      final whatReceived = data != null ? jsonEncode(data) : "null";
      TrackingManager.recordError(new Exception("Zalo login failed, $whatReceived"), s);
    }
    throw ZaloLoginException('Login failed');
  }
}

class ZaloLoginResult {
  String accessToken;
  String refreshToken;
  int? expiresIn;
  int? refreshTokenExpiresIn;
  String id;
  String name;

  ZaloLoginResult({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.refreshTokenExpiresIn,
    required this.id,
    required this.name,
  });

  factory ZaloLoginResult.fromJson(
      Map<dynamic, dynamic> json, Map<dynamic, dynamic> profile) {
    return ZaloLoginResult(
        accessToken: json['access_token'] ?? json['accessToken'],
        refreshToken: json['refresh_token'] ?? json['refreshToken'],
        expiresIn: json['expires_in'] != null
            ? int.tryParse(json['expires_in'].toString())
            : null,
        refreshTokenExpiresIn: json['refresh_token_expires_in'] != null
            ? int.tryParse(json['refresh_token_expires_in'].toString())
            : null,
        id: profile['id'],
        name: profile['name']);
  }
}

class ZaloLoginException implements Exception {
  final String message;
  ZaloLoginException(this.message);
}
