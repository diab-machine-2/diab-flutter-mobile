import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteSetting {
  FirebaseRemoteSetting._privateConstructor();
  static final FirebaseRemoteSetting instance = FirebaseRemoteSetting._privateConstructor();
  final remoteConfig = FirebaseRemoteConfig.instance;

  late String _appStoreVersion;
  late String _playStoreVersion;
  late String? _storeNavigationUrl;
  late bool _activePopupHealthConnect; //ACTIVE_POPUP_HEALTH_CONNECT
  late String _linkStoreNavigation;
  bool? _appDeveloperMode = false;

  String get appStoreVersion => _appStoreVersion;
  String get playStoreVersion => _playStoreVersion;
  String get storeNavigationUrl {
    return _storeNavigationUrl ?? 'https://diab.com.vn/ve-diab/';
  }

  bool get activePopupHealthConnect => _activePopupHealthConnect;
  String get linkStoreNavigation => _linkStoreNavigation;
  bool get appDeveloperMode => _appDeveloperMode ?? false;

  Future<void> init() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    // final List<Future<void>> setupFutures = [
    //   remoteConfig.setConfigSettings(RemoteConfigSettings(
    //     fetchTimeout: const Duration(seconds: 10),
    //     minimumFetchInterval: const Duration(seconds: 10),
    //   )),
    //   remoteConfig.fetchAndActivate(),
    // ];
    // Future.value(setupFutures);
    // Only wait when not finished yet
    if (remoteConfig.getString('APP_STORE_VERSION') == "") {
      // await Future.delayed(const Duration(seconds: 10));
      return;
    }
    _appStoreVersion = remoteConfig.getString('APP_STORE_VERSION');
    _playStoreVersion = remoteConfig.getString('PLAY_STORE_VERSION');
    _storeNavigationUrl = remoteConfig.getString('STORE_NAVIGATION_URL');
    _activePopupHealthConnect = remoteConfig.getBool('ACTIVE_POPUP_HEALTH_CONNECT');
    _linkStoreNavigation = remoteConfig.getString('LINKSTORE_NAVIGATION_URL');
    _appDeveloperMode = remoteConfig.getBool('APP_DEVELOPER_MODE');
  }
}
