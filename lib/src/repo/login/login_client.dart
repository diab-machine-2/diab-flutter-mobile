import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/login/login_model.dart';
import 'package:medical/src/modal/register/register_model.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginClient extends FetchClient {
  Future<LoginModel> login(Map<String, dynamic> params) async {
    try {
      final Response<dynamic> response = await super
          .postUri(baseIdentify: true, url: '/connect/token', params: params);
      Console.log('login', response.statusCode);
      Console.log('response', response.data);
      if (response.statusCode == 200) {
        final loginModel = LoginModel.fromJson(response.data);
        await AppSettings.saveToken(loginModel.access_token);
        await AppSettings.saveRefreshToken(loginModel.refresh_token);
        return loginModel;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> checkExistPhoneNumber(String phone) async {
    // try {
    final Response<dynamic> response = await super.fetchData(
      baseIdentify: true,
      url: '/api/auth/v1/mobile/register/exist',
      params: {'phoneNumber': phone},
    );
    if (response.statusCode == 200) {
      return response.data['isExistAccount'] ?? false;
    } else {
      final error = Error.fromJson1(response);
      throw error;
    }
    // } catch (e) {
    //   throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }

  Future<RegisterModel> submitRegister(String phone) async {
    // try {
    final Response<dynamic> response = await super.postUri(
      baseIdentify: true,
      baseOption: true,
      url: '/api/auth/v1/mobile/register',
      params: {
        'phoneNumber': phone,
        'password': "123@56789",
      },
    );
    if (response.statusCode == 200) {
      return RegisterModel.fromJson(response.data);
    } else {
      final error = Error.fromJson1(response);
      throw error;
    }
    // } catch (e) {
    //   throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }

  Future<bool> submitUpdatePasswordRegister({
    required String phone,
    required String password,
  }) async {
    // try {
    final Response<dynamic> response = await super.postUri(
      baseIdentify: true,
      baseOption: true,
      url: '/api/auth/v1/mobile/register/complete',
      params: {
        'phoneNumber': phone,
        'password': password,
        'OldPassword': "123@56789",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = Error.fromJson1(response);
      throw error;
    }
    // } catch (e) {
    //   throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }

  Future<RegisterModel> requestOTP(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/auth/v1/mobile/register',
          params: params);
      if (response.statusCode == 200) {
        return RegisterModel.fromJson(response.data);
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<LoginModel> resendOTP(String phone, String otp) async {
    try {
      Map<String, dynamic> params = Map<String, String>();
      params['phone'] = phone;
      final Response<dynamic> response = await super.fetchData(
          baseIdentify: true,
          url: '/Otp/Resend',
          params: params as Map<String, String?>?);
      if (response.statusCode == 200) {
        return LoginModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> verifyOTP(String? phone, String otp) async {
    try {
      final Response response = await super.putData(
          baseIdentify: true,
          url: '/api/auth/v1/mobile/register/verify',
          params: {'phoneNumber': phone, 'token': otp});
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<LoginModel> loginOTP(
      // String code, String otpId, String password
      ) async {
    try {
      final Response<dynamic> response =
          await super.postData(baseIdentify: true, url: '/Identity/Otp');
      if (response.statusCode == 200) {
        final loginModel = LoginModel.fromJson(response.data['data']);
        return loginModel;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> syncToken(String? deviceID, String? token, int platform) async {
    try {
      final Response response = await super.postUri(
          baseOption: true,
          url:
              '/App/Device', //?deviceInformation=$deviceID&firebaseToken=$token&deviceType=$platform',

          params: {
            'deviceInformation': deviceID,
            'firebaseToken': token,
            'deviceType': platform.toString()
          });
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> logout() async {
    try {
      final firebaseToken = await FirebaseMessaging.instance.getToken();
      final Response response =
          await super.delete(url: '/App/Device/Input/$firebaseToken');
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> createPatient(Map<String, dynamic> params) async {
    try {
      final response = await super.postData(
        url: '/App/Patient/Input',
        params: FormData.fromMap(params),
      );
      Console.log('createPatient', response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<RegisterModel> requestOTPRecover(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/recover',
          params: params);
      if (response.statusCode == 200) {
        return RegisterModel.fromJson(response.data);
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> verifyOTPRecover(String? phoneNumber, String token) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/recover/verify',
          params: {"phoneNumber": phoneNumber, "token": token});
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> resetPassword(
      String? phoneNumber, String password, String? token) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/password/reset',
          params: {
            "phoneNumber": phoneNumber,
            "password": password,
            "token": token
          });
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final Response<dynamic> response = await super.putData(
          baseIdentify: true,
          //baseOption: true,
          url: '/api/Account/v1/users/current/password',
          params: {
            "currentPassword": currentPassword,
            "newPassword": newPassword
          });
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw response.data.toString();
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> changePhoneNumber(String phone) async {
    try {
      final Response<dynamic> response = await super.putData(
          url: '/app/Account/Current/phone-number',
          params: {"phoneNumber": phone});
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<String?> fetchTermAndCondition() async {
    try {
      final Response<dynamic> response = await super.fetchData(
        url: '/App/TermAndCondition',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<RegisterModel> registerWithSocial(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/external/register',
          params: params);
        Console.log('registerWithSocial', response.statusCode);
        Console.log('response', response.data);
      if (response.statusCode == 200) {
        return RegisterModel.fromJson(response.data);
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<RegisterModel> linkedAccountOTP(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/external/link-account-otp',
          params: params);
      if (response.statusCode == 200) {
        return RegisterModel.fromJson(response.data);
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> linkedAccount(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/external/link-account',
          params: params);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> unLinkedAccount(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/external/unlink-account',
          params: params);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> appLogs(Map<String, dynamic> errorData) async {
    try {
      final Response<dynamic> response = await super.postUri(
        baseIdentify: false,
        baseOption: true,
        url: '/App/Logs',
        params: errorData,
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
