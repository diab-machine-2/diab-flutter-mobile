import 'package:meta/meta.dart';

class RegisterModel {
  final String? token;
  final int? remainingRequestCount;
  final bool? isSuccess;

  RegisterModel({
    required this.token,
    required this.remainingRequestCount,
    required this.isSuccess,
  });
  @override
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
        token: json['token'] ?? null,
        remainingRequestCount: json['remainingRequestCount'],
        isSuccess: json['isSuccess']);
  }
}
