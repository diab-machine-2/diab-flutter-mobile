import 'dart:convert';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/base/base_model.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:meta/meta.dart';

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

  // factory Error.fromJson(Map<String, dynamic> json) {
  //   return Error(
  //       code: json['code'], message: json['message'], error: json['error']);
  // }
  factory Error.fromJson(Response<dynamic> response) {
    if (response.statusMessage == 'Unauthorized') {
      DartNotificationCenter.post(channel: 'unauthorized');
    }
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

  static fromJson1(Response<dynamic> response) {
    final errorCode = response.data['errorCode'] != null
        ? response.data['errorCode']
        : response.data['code'] != null
            ? response.data['code']
            : '';
    return Error(
        code: errorCode.toString(), message: '', error: response.data['error']);
  }
}
