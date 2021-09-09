import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medical/app_setting/app_setting.dart';
import 'package:medical/modal/login/login_model.dart';
import 'package:medical/modal/register/register_model.dart';
import 'package:medical/widget/helper/http_helper.dart';
import 'package:medical/modal/error/error_model.dart';
import 'package:medical/widget/helper/http_helper.dart';

class LoginClient extends FetchClient {
  Future<LoginModel> login(Map<String, dynamic> params) async {
    try {
      final Response<dynamic> response = await super
          .postUri(baseIdentify: true, url: '/connect/token', params: params);
      if (response.statusCode == 200) {
        final loginModel = LoginModel.fromJson(response.data);
        print(loginModel);
        await AppSettings.saveToken(loginModel.access_token);
        await AppSettings.saveRefreshToken(loginModel.refresh_token);
        return loginModel;
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<LoginModel> resendOTP(String phone, String otp) async {
    try {
      Map<String, dynamic> params = Map<String, String>();
      params['phone'] = phone;
      final Response<dynamic> response = await super
          .fetchData(baseIdentify: true, url: '/Otp/Resend', params: params);
      if (response.statusCode == 200) {
        return LoginModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> verifyOTP(String phone, String otp) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> syncToken(String deviceID, String token, int platform) async {
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
        print('send token success: $token');
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> logout() async {
    try {
      final firebaseToken = await FirebaseMessaging.instance.getToken();
      final Response response =
          await super.delete(url: '/App/Device/Input/$firebaseToken');
      print(response);
      if (response.statusCode == 200) {
        print('logout success');
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> createPatient(Map<String, String> params) async {
    try {
      final response = await super
          .postHttp(path: '/App/Patient/Input', params: params, files: []);
      if (response.statusCode == 200) {
        print('register success');
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> verifyOTPRecover(String phoneNumber, String token) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> resetPassword(
      String phoneNumber, String password, String token) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<String> fetchTermAndCondition() async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<RegisterModel> registerWithSocial(params) async {
    try {
      final Response<dynamic> response = await super.postUri(
          baseIdentify: true,
          baseOption: true,
          url: '/api/Auth/v1/mobile/external/register',
          params: params);
      if (response.statusCode == 200) {
        return RegisterModel.fromJson(response.data);
      } else {
        final error = Error.fromJson1(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }
}
