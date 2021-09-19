import 'dart:convert';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/main.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical/src/modal/user/user_model.dart';

class AppSettings {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static UserModel userInfo;

  static Future<bool> saveToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('token', token);
    return true;
  }

  static Future<String> getToken() async {
    final SharedPreferences prefs = await _prefs;
    final token = prefs.getString('token') ?? '';
    print(token);
    return token;
  }

  static Future<bool> clearToken() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('token', '');
    return true;
  }

  static Future<bool> saveRefreshToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('refresh_token', token);
    return true;
  }

  static Future<String> getRefreshToken() async {
    final SharedPreferences prefs = await _prefs;
    final token = prefs.getString('refresh_token') ?? '';
    print(token);
    return token;
  }

  static Future<bool> clearRefreshToken() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('refresh_token', '');
    return true;
  }

  static Future<bool> saveTokenLifeTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('token_life_time', now + time);
    return true;
  }

  static Future<int> getTokenLifeTime() async {
    final SharedPreferences prefs = await _prefs;
    final time = prefs.getInt('token_life_time') ?? 0;
    return time;
  }

  static Future<bool> clearTokenLifeTime() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt('token_life_time', 0);
    return true;
  }

  static Future<bool> saveHome(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('home_data', jsonString);
    return true;
  }

  static Future<HomeModel> getHome() async {
    final SharedPreferences prefs = await _prefs;
    final userData = prefs.getString('home_data') ?? '';
    if (userData.isEmpty) {
      return null;
    }
    final jsonData = json.decode(userData);
    final data = HomeModel.fromJson(jsonData);
    return data;
  }

  static Future<bool> deleteHomeData() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('home_data', '');
    return true;
  }

  static Future<bool> saveSettings(dynamic setting) async {
    final jsonString = jsonEncode(setting);
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('setting', jsonString);
    return true;
  }

  static Future<dynamic> getSettings() async {
    final SharedPreferences prefs = await _prefs;
    final settingData = prefs.getString('setting') ?? '';
    final jsonData = json.decode(settingData);
    return jsonData;
  }

  static Future<bool> checkToken() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tokenLifetime = await getTokenLifeTime();
    if (tokenLifetime > now) {
      return true;
    } else {
      DartNotificationCenter.post(channel: 'token_time_out');
      await logout();
      return false;
    }
  }

  static Future<bool> logout() async {
    try {
      navigatorKey.currentState.popUntil((route) => route.isFirst);
      navigatorKey.currentState.pushReplacementNamed(NavigatorName.step_list);
      await FetchClient().checkNetwork();
      await LoginClient().logout();
      await clearToken();
      await clearRefreshToken();
      GoogleSignIn _googleSignIn = GoogleSignIn();
      _googleSignIn.signOut();
      final facebookLogin = FacebookLogin();
      facebookLogin.logOut();
      return true;
    } catch (_) {
      return false;
    }
  }
}
