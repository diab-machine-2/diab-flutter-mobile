import 'package:medical/src/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  AppPreference._privateConstructor();

  static final AppPreference _instance = AppPreference._privateConstructor();

  factory AppPreference() {
    SharedPreferences.getInstance().then((value) {
      _instance._preference = value;
    });
    return _instance;
  }

  SharedPreferences? _preference;

  String get appLanguage {
    return _preference?.getString(Const.key_app_language) ?? Const.VI;
  }

  void saveAppLanguage(String language) {
    _preference?.setString(Const.key_app_language, language);
  }

  // void saveData(UserData user) {
  //   setData(Const.ID, user.customerId);
  //   setData(Const.FULL_NAME, user.fullName);
  //   setData(Const.PHONE, user.phoneNumber);
  //   setData(Const.EMAIL, user.email);
  //   setData(Const.CITY, user.shippingCityName);
  //   setData(Const.DISTRICT, user.shippingDistrictName);
  //   setData(Const.ADDRESS, user.shippingAddress);
  //   setData(Const.POINT, user.moneyPoint);
  //   setData(Const.CITY_ID, user.shippingCityId);
  //   // TODO save important data
  // }
  //
  // void clearData() {
  //   removeData(Const.TOKEN);
  //   removeData(Const.PHONE);
  //   removeData(Const.FULL_NAME);
  // }

  String? getData(String key) {
    return _preference?.getString(key);
  }

  List<String>? getStringList(String key) {
    return _preference?.getStringList(key);
  }

  int? getIntData(String key) {
    return _preference?.getInt(key);
  }

  void setData(String key, Object? data) {
    if (data == null) return;
    if (data is int) {
      _preference?.setInt(key, data);
    }
    if (data is String) {
      _preference?.setString(key, data);
    }
    if (data is bool) {
      _preference?.setBool(key, data);
    }
    if (data is List<String>) {
      _preference?.setStringList(key, data);
    }
  }

  void removeData(String key) {
    _preference?.remove(key);
  }
}

AppPreference appPreference = AppPreference();
