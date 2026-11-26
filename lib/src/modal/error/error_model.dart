import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/base/base_model.dart';

class ErrorModel extends BaseModel {
  String? code;
  String? message;
  String? error;

  ErrorModel({this.code, this.message});
  @override
  fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    error = json['error'];
  }
}

class Error {
  final String? code;
  final String? message;
  final String? error;

  Error({required this.code, required this.message, required this.error});

  @override
  String toString() => 'Error(code: $code, message: $message, error: $error)';

  // factory Error.fromJson(Map<String, dynamic> json) {
  //   return Error(
  //       code: json['code'], message: json['message'], error: json['error']);
  // }
  factory Error.fromJson(Response<dynamic> response,
      {bool isSyncAccount = false}) {
    if (response.statusMessage == 'Unauthorized' && !isSyncAccount) {
      Observable.instance.notifyObservers([], notifyName: "unauthorized");
      // DartNotificationCenter.post(channel: 'unauthorized');
    }
    final serverError = Error.fromServerStatus(response.statusCode);
    if (serverError != null) return serverError;
    final json = response.data['error'];
    return Error(
        code: json['code'], message: json['message'], error: json['error']);
  }

  static fromString(String error) {
    final json = jsonDecode(error);
    final data = json['error'];
    return Error(
        code: data['code'], message: data['message'], error: data['error']);
  }

  /// Any 5xx → "Hệ thống đang gặp sự cố". The body of a 5xx is a crash dump
  /// or a raw backend message, never something to show the user (and often
  /// not JSON, which used to throw here and surface as "can't connect").
  static Error? fromServerStatus(int? statusCode) {
    if (statusCode == null || statusCode < 500 || statusCode >= 600) {
      return null;
    }
    return Error(
      code: 'HTTP_$statusCode',
      message: R.string.error_system_problem.tr(),
      error: null,
    );
  }

  static fromJson1(Response<dynamic> response) {
    final serverError = Error.fromServerStatus(response.statusCode);
    if (serverError != null) return serverError;
    final errorCode = response.data['errorCode'] != null
        ? response.data['errorCode']
        : response.data['code'] != null
            ? response.data['code']
            : '';
    return Error(
        code: errorCode.toString(), message: '', error: response.data['error']);
  }
}
