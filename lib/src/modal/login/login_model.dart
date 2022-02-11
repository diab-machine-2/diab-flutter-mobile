import 'package:meta/meta.dart';

@immutable
class LoginModel {
  final String? id_token;
  final String? access_token;
  final int? experis_in;
  final String? token_type;
  final String? refresh_token;
  final String? scope;

  const LoginModel({
    required this.id_token,
    required this.access_token,
    required this.experis_in,
    required this.token_type,
    required this.refresh_token,
    required this.scope,
  });
  @override
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
        id_token: json['id_token'],
        access_token: json['access_token'],
        experis_in: json['expires_in'],
        token_type: json['token_type'],
        refresh_token: json['refresh_token'],
        scope: json['scope']);
  }
}
