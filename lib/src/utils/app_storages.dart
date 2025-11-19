import 'dart:convert';
import 'package:medical/src/modal/base/referral_code_temp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorages {
  static Future setReferralCode(ReferralCodeTemp? referralCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('referralCode', jsonEncode(referralCode!.toJson()));
  }

  static Future setHealthAppPermission(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('healthAppPermission', '$value');
  }

  static Future getHealthAppPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('healthAppPermission') != null) {
      String prefData = prefs.getString('healthAppPermission').toString();
      return prefData == 'true';
    }
    return null;
  }

  static Future<ReferralCodeTemp?> getReferralCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('referralCode') != null) {
      String prefData = prefs.getString('referralCode').toString();
      var data = jsonDecode(prefData);
      return ReferralCodeTemp.fromJson(data);
    }
    return null;
  }

  static Future<void> removeReferralCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("referralCode");
  }

  // HbA1C Onboarding Methods
  static Future<bool> isFirstTimeHbA1C() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTimeHbA1C') ?? true;
  }

  static Future<void> setHbA1COnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeHbA1C', false);
  }

  static Future<void> resetHbA1COnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isFirstTimeHbA1C');
  }

  // HbA1C Notification Badge Methods
  static Future<bool> isHbA1CDetailViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hba1c_detail_viewed') ?? false;
  }

  static Future<void> setHbA1CDetailViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hba1c_detail_viewed', true);
  }

  static Future<void> resetHbA1CDetailViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('hba1c_detail_viewed');
  }

  static final AppStorages _instance = AppStorages._internal();
  factory AppStorages() {
    return _instance;
  }
  AppStorages._internal();
}
