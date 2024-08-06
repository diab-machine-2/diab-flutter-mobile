import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:medical/src/app_setting/app_setting.dart';

class FirebaseRemoteSetting {
  FirebaseRemoteSetting._privateConstructor();
  static final FirebaseRemoteSetting instance =
      FirebaseRemoteSetting._privateConstructor();
  final remoteConfig = FirebaseRemoteConfig.instance;

  late String _appStoreVersion;
  late String _playStoreVersion;
  late String? _storeNavigationUrl;
  late bool _activePopupHealthConnect; //ACTIVE_POPUP_HEALTH_CONNECT
  late String _linkStoreNavigation;
  String? _utilitiesOrder;
  bool? _appDeveloperMode = false;

  String get appStoreVersion => _appStoreVersion;
  String get playStoreVersion => _playStoreVersion;
  String get storeNavigationUrl {
    return _storeNavigationUrl ?? 'https://diab.com.vn/ve-diab/';
  }

  bool get activePopupHealthConnect => _activePopupHealthConnect;
  String get linkStoreNavigation => _linkStoreNavigation;
  bool get appDeveloperMode => _appDeveloperMode ?? false;
  String? get utilitiesOrder => _utilitiesOrder;

  Future<void> init({Duration timeout = const Duration(seconds: 10)}) async {
    // Get local settings
    var localSettings = await AppSettings.getFirebaseRemoteSettings();
    Map<String, dynamic> localSetting =
        localSettings.isNotEmpty ? jsonDecode(localSettings) : {};
    // Set default for settings if fetch fail
    await remoteConfig.setDefaults({
      "APP_STORE_VERSION": localSetting["APP_STORE_VERSION"] ?? '1.4.3',
      "PLAY_STORE_VERSION": localSetting["PLAY_STORE_VERSION"] ?? '1.4.5',
      "STORE_NAVIGATION_URL": localSetting["STORE_NAVIGATION_URL"] ??
          'https://chuongtrinh.diab.com.vn/',
      "ACTIVE_POPUP_HEALTH_CONNECT":
          bool.parse(localSetting["ACTIVE_POPUP_HEALTH_CONNECT"] ?? "false"),
      "LINKSTORE_NAVIGATION_URL": localSetting["LINKSTORE_NAVIGATION_URL"] ??
          "{\"Lazada\":\"https://www.lazada.vn/shop/diab-official123/?spm=a2o4n.pdp_revamp.seller.1.22551b10iVUR71&itemId=2204466993&channelSource=pdp\",\"Shopee\":\"https://shopee.vn/diab_official123?categoryId=100001&entryPoint=ShopByPDP&itemId=17493490410\",\"Store\":\"https://store.diab.com.vn\"}",
      "APP_DEVELOPER_MODE":
          bool.parse(localSetting["APP_DEVELOPER_MODE"] ?? "true"),
      "UTILITIES_ORDER":
          "lich-do-duong-huyet,thuc-don-mau,thiet-lap-muc-tieu,ket-noi-thiet-bi,moi-ban-be,lich-uong-thuoc,tu-van-bac-si",
    });
    // Config timeout for remoteConfig
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: timeout,
      minimumFetchInterval: const Duration(minutes: 5),
    ));

    /**
     * if fetch success it get all config save local and set retry false
     * else set retry true to retry fetch again in login screen
     */
    try {
      await remoteConfig.fetchAndActivate();
      Map<String, RemoteConfigValue> allValues = remoteConfig.getAll();
      Map<String, String> parsedValues = {};
      for (var entry in allValues.entries) {
        String key = entry.key;
        RemoteConfigValue value = entry.value;
        String parsedValue = value.asString();
        parsedValues[key] = parsedValue;
      }
      String settings = jsonEncode(parsedValues);
      await AppSettings.setFirebaseRemoteSettings(settings);
      await AppSettings.setIsRetryFetchFirebaseRemoteConfig(false);
    } catch (e) {
      await AppSettings.setIsRetryFetchFirebaseRemoteConfig(true);
    }

    _appStoreVersion = remoteConfig.getString('APP_STORE_VERSION');
    _playStoreVersion = remoteConfig.getString('PLAY_STORE_VERSION');
    _storeNavigationUrl = remoteConfig.getString('STORE_NAVIGATION_URL');
    _activePopupHealthConnect =
        remoteConfig.getBool('ACTIVE_POPUP_HEALTH_CONNECT');
    _linkStoreNavigation = remoteConfig.getString('LINKSTORE_NAVIGATION_URL');
    _appDeveloperMode = remoteConfig.getBool('APP_DEVELOPER_MODE');
    _utilitiesOrder = remoteConfig.getString('UTILITIES_ORDER');
  }
}
