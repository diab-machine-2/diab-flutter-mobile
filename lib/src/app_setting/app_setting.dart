import 'dart:convert';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/user/category_user_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

import '../modal/user/secure.dart';

class AppSettings {
  static UserModel? userInfo;
  static bool isGetUser = false;
  static List<SmartGoalList?> smartGoalDayList = [];
  static CategoryUserModel? categoryUserModel;
  static int? currentDateTime;
  static String environment = "";
  static SecureModel? secureModel;
  static bool isDisplayedWelcome = false;
  static String currentScreenName = '';
  static String? version;
  static String? buildNumber;

  static bool showed50Message = false;
  static bool showed90Message = false;

  static bool isReloadCurrentUserInfo = false;

  static Future<bool> saveEnvironment(String? env) async {
    appPreference.setData(Const.ENVIRONMENT, env);
    return true;
  }

  static Future<String> getEnvironment() async {
    final env = appPreference.getData(Const.ENVIRONMENT) ?? '';
    return env;
  }

  static Future<bool> clearEnvironment() async {
    appPreference.removeData(Const.ENVIRONMENT);
    return true;
  }

  static Future<bool> saveToken(String? token) async {
    Console.log("saveToken", token);
    appPreference.setData(Const.TOKEN, token);
    return true;
  }

  static Future<String> getToken() async {
    final token = appPreference.getData(Const.TOKEN) ?? '';
    Console.log("getToken", token);
    return token;
  }

  static Future<bool> clearToken() async {
    appPreference.removeData(Const.TOKEN);
    appPreference.removeData('healthAppPermission');
    return true;
  }

  static Future<bool> saveRefreshToken(String? token) async {
    appPreference.setData(Const.REFRESH_TOKEN, token);
    return true;
  }

  static Future<String> getRefreshToken() async {
    final token = appPreference.getData(Const.REFRESH_TOKEN) ?? '';
    return token;
  }

  static Future<bool> clearRefreshToken() async {
    appPreference.removeData(Const.REFRESH_TOKEN);
    return true;
  }

  static Future<bool> saveTokenLifeTime(int time) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    appPreference.setData('token_life_time', now + time);
    return true;
  }

  static Future<int> getTokenLifeTime() async {
    final time = appPreference.getIntData('token_life_time') ?? 0;
    return time;
  }

  static Future<bool> clearTokenLifeTime() async {
    appPreference.removeData('token_life_time');
    return true;
  }

  static Future<bool> saveHome(Map<String, dynamic>? data) async {
    final jsonString = jsonEncode(data);
    appPreference.setData('home_data', jsonString);
    return true;
  }

  static Future<HomeModel?> getHome() async {
    final userData = appPreference.getData('home_data') ?? '';
    if (userData.isEmpty) {
      return null;
    }
    final jsonData = json.decode(userData);
    final data = HomeModel.fromJson(jsonData);
    return data;
  }

  static Future<bool> deleteHomeData() async {
    appPreference.removeData('home_data');
    return true;
  }

  static Future<bool> saveSettings(dynamic setting) async {
    final jsonString = jsonEncode(setting);
    appPreference.setData('setting', jsonString);
    return true;
  }

  static Future<dynamic> getSettings() async {
    final settingData = appPreference.getData('setting') ?? '';
    final jsonData = json.decode(settingData);
    return jsonData;
  }

  static Future<bool> checkToken() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tokenLifetime = await getTokenLifeTime();
    if (tokenLifetime > now) {
      return true;
    } else {
      Observable.instance.notifyObservers([], notifyName: "token_time_out");
      // DartNotificationCenter.post(channel: 'token_time_out');
      await logout();
      return false;
    }
  }

  static Future<bool> saveNiproDevices(
      List<Map<String, String>>? devices) async {
    final jsonString = jsonEncode(devices);
    appPreference.setData(Const.NIPRO_DEVICES, jsonString);
    return true;
  }

  static List<Map<String, String>> getNiproDevices() {
    final data = appPreference.getData(Const.NIPRO_DEVICES) ?? '';
    if (data.isEmpty) {
      return [];
    }
    final listData = json.decode(data) as List;
    return listData.map((e) => Map<String, String>.from(e)).toList();
  }

  static Future<bool> logout({bool isNavigateToStepListScreen = true}) async {
    try {
      if (isNavigateToStepListScreen) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
        navigatorKey.currentState!
            .pushReplacementNamed(NavigatorName.step_list);
      }

      await FetchClient().checkNetwork();
      await LoginClient().logout();
      await deleteHomeData();
      await clearToken();
      await clearRefreshToken();
      appPreference.removeData("hasNewReports");
      appPreference.removeData("reports");
      appPreference.removeData("user");
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      _googleSignIn.signOut();
      final facebookLogin = FacebookLogin();
      facebookLogin.logOut();
      return true;
    } catch (_) {
      return false;
    }
  }
}
