import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteSetting {
  FirebaseRemoteSetting._privateConstructor();
  static final FirebaseRemoteSetting instance =
      FirebaseRemoteSetting._privateConstructor();
  final remoteConfig = FirebaseRemoteConfig.instance;

  late String _appStoreVersion;
  late String _playStoreVersion;
  String? _storeNavigationUrl;
  bool? _appDeveloperMode = false;

  String get appStoreVersion => _appStoreVersion;
  String get playStoreVersion => _playStoreVersion;
  String get storeNavigationUrl {
    return _storeNavigationUrl ?? 'https://diab.com.vn/ve-diab/';
  }
  bool get appDeveloperMode => _appDeveloperMode ?? false;

  Future<void> init() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 10),
    ));
    await remoteConfig.fetchAndActivate();
    _appStoreVersion = remoteConfig.getString('APP_STORE_VERSION');
    _playStoreVersion = remoteConfig.getString('PLAY_STORE_VERSION');
    _storeNavigationUrl = remoteConfig.getString('STORE_NAVIGATION_URL');
    _appDeveloperMode = remoteConfig.getBool('APP_DEVELOPER_MODE');
  }
}