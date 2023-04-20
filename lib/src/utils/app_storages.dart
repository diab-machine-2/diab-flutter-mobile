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

  static final AppStorages _instance = AppStorages._internal();
  factory AppStorages() {
    return _instance;
  }
  AppStorages._internal();
}
