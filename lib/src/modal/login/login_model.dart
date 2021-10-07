import 'package:meta/meta.dart';

class LoginModel {
  final String? access_token;
  final int? experis_in;
  final String? token_type;
  final String? refresh_token;
  final String? scope;

  LoginModel({
    required this.access_token,
    required this.experis_in,
    required this.token_type,
    required this.refresh_token,
    required this.scope,
  });
  @override
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
        access_token: json['access_token'] ?? null,
        experis_in: json['experis_in'] ?? null,
        token_type: json['token_type'] ?? null,
        refresh_token: json['refresh_token'] ?? null,
        scope: json['scope'] ?? null);
  }
}
