import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/glucose/glucose_faq.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class FirebaseRemoteSetting {
  FirebaseRemoteSetting._privateConstructor();
  static final FirebaseRemoteSetting instance =
      FirebaseRemoteSetting._privateConstructor();
  final remoteConfig = FirebaseRemoteConfig.instance;

  // Minimum app version required per platform (force update). Empty = no
  // forced update. Non-`late` on purpose: they're read on app resume and may
  // be accessed before `init()` finishes (it can outlive the splash timeout).
  String _appStoreVersion = '';
  String _playStoreVersion = '';
  final Completer<void> _initialized = Completer<void>();

  /// Completes once `init()` has populated values (fetched, cached or
  /// defaults) — regardless of whether the caller's own timeout fired first.
  Future<void> get initialized => _initialized.future;
  late String? _storeNavigationUrl;
  late bool _activePopupHealthConnect; //ACTIVE_POPUP_HEALTH_CONNECT
  late String _linkStoreNavigation;
  String? _utilitiesOrder;
  // Specialty codes per booking flow, read by SpecialtyCatalog.forBooking.
  // "dd" (Dạ dày/Tiêu hoá) is left out on purpose.
  static const String defaultBookingSpecialtyList =
      '{"at_clinic":["dinh-duong","van-dong","tcbp","tt","tdtd","dtd","dtdtk","rlch","tha","tm","tmt","cxk"],'
      '"telemedicine":["dinh-duong","van-dong","tcbp","tt","tdtd","dtd","dtdtk","rlch","tha","tm","tmt"]}';
  String _bookingSpecialtyList = defaultBookingSpecialtyList;
  List<GlucoseFaq> _glucoseFaqs = [
    GlucoseFaq(
      title: 'Máy đo của bạn không thuộc danh sách thiết bị hỗ trợ?',
      linkTitle: 'Xem chương trình Thu cũ đổi mới của DiaB',
      url:
          'https://diab.com.vn/nang-cap-may-do-duong-huyet-tai-benh-vien-dong-nai-2-co-hoi-tiet-kiem-200-000d-va-cham-soc-suc-khoe-toan-dien/',
    ),
    GlucoseFaq(
      title: 'Bạn chưa có máy đo đường huyết?',
      linkTitle:
          'Tìm hiểu về lợi ích máy đo đường huyết có kết nối với ứng dụng DiaB',
      url:
          'https://diab.com.vn/tim-hieu-loi-ich-cua-may-do-duong-huyet-co-ket-noi-voi-ung-dung-diab/',
    ),
  ];
  bool? _appDeveloperMode = false;
  String? _vnpayIntegratedInfo;
  String? _subscriptionPackageInfo;
  String? _benefitAtHomeInfo;
  // Parsed (with in-code defaults) by HomeBenefitShortcutsConfig /
  // HomeDailyCareConfig in lib/src/widget/home/home_remote_config.dart.
  String _homeBenefitShortcuts = '';
  String _homeDailyCareConfig = '';

  String get appStoreVersion => _appStoreVersion;
  String get playStoreVersion => _playStoreVersion;
  String get storeNavigationUrl {
    return _storeNavigationUrl ?? 'https://diab.com.vn/ve-diab/';
  }

  bool get activePopupHealthConnect => _activePopupHealthConnect;
  String get linkStoreNavigation => _linkStoreNavigation;
  bool get appDeveloperMode => _appDeveloperMode ?? false;
  String? get utilitiesOrder => _utilitiesOrder;
  List<GlucoseFaq> get glucoseFaqs => _glucoseFaqs;
  String? get vnpayIntegratedInfo => _vnpayIntegratedInfo;
  String? get subscriptionPackageInfo => _subscriptionPackageInfo;
  String? get benefitAtHomeInfo => _benefitAtHomeInfo;
  String get bookingSpecialtyList => _bookingSpecialtyList;
  String get homeBenefitShortcuts => _homeBenefitShortcuts;
  String get homeDailyCareConfig => _homeDailyCareConfig;

  Future<void> init({Duration timeout = const Duration(seconds: 10)}) async {
    // Get local settings
    var localSettings = await AppSettings.getFirebaseRemoteSettings();
    // A corrupt saved copy must not throw here: that would skip completing
    // [initialized] and silently disable the force-update check.
    Map<String, dynamic> localSetting = {};
    try {
      if (localSettings.isNotEmpty) localSetting = jsonDecode(localSettings);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
    // Set default for settings if fetch fail
    try {
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
      "UTILITIES_ORDER": localSetting["UTILITIES_ORDER"] ??
          "thiet-lap-muc-tieu,lich-do-duong-huyet,lich-uong-thuoc,ket-noi-thiet-bi,kham-tu-xa,tu-van-song-khoe,dat-lich-kham-benh,thuc-don-mau,lich-nhac-nho",
      "GLUCOSE_FAQS":
          jsonEncode(_glucoseFaqs.map((faq) => faq.toJson()).toList()),
      "VNPAY_INTEGRATED_INFO": localSetting["VNPAY_INTEGRATED_INFO"] ?? '',
      "VNPAY_INTEGRATED_INFO_DEV":
          localSetting["VNPAY_INTEGRATED_INFO_DEV"] ?? '',
      "SUBSCRIPTION_PACKAGE_INFO":
          localSetting["SUBSCRIPTION_PACKAGE_INFO"] ?? '',
      "BENEFIT_AT_HOME_INFO": localSetting["BENEFIT_AT_HOME_INFO"] ?? '',
      // Always the in-code list: a cached copy would outlive future defaults.
      "BOOKING_SPECIALTY_LIST": defaultBookingSpecialtyList,
      "HOME_BENEFIT_SHORTCUTS": localSetting["HOME_BENEFIT_SHORTCUTS"] ?? '',
      "HOME_DAILY_CARE_CONFIG": localSetting["HOME_DAILY_CARE_CONFIG"] ?? '',
      }).timeout(const Duration(seconds: 5));
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
    // Config timeout for remoteConfig
    try {
      await remoteConfig
          .setConfigSettings(RemoteConfigSettings(
            fetchTimeout: timeout,
            minimumFetchInterval: const Duration(minutes: 5),
          ))
          .timeout(const Duration(seconds: 5));
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }

    /**
     * if fetch success it get all config save local and set retry false
     * else set retry true to retry fetch again in login screen
     */
    try {
      await remoteConfig.fetchAndActivate().timeout(timeout);
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
    // Complete right after the version keys are read, so a later parsing
    // error (e.g. malformed GLUCOSE_FAQS JSON) can't block the update check.
    if (!_initialized.isCompleted) _initialized.complete();
    _storeNavigationUrl = remoteConfig.getString('STORE_NAVIGATION_URL');
    _activePopupHealthConnect =
        remoteConfig.getBool('ACTIVE_POPUP_HEALTH_CONNECT');
    _linkStoreNavigation = remoteConfig.getString('LINKSTORE_NAVIGATION_URL');
    _appDeveloperMode = remoteConfig.getBool('APP_DEVELOPER_MODE');
    _utilitiesOrder = remoteConfig.getString('UTILITIES_ORDER');
    // Read before GLUCOSE_FAQS, whose parsing can throw. Empty (setDefaults
    // failed and no fetch) keeps the in-code default, which hides "dd".
    final bookingSpecialtyList =
        remoteConfig.getString('BOOKING_SPECIALTY_LIST');
    if (bookingSpecialtyList.isNotEmpty) {
      _bookingSpecialtyList = bookingSpecialtyList;
    }
    // A malformed GLUCOSE_FAQS must not skip the keys read after it (VNPay,
    // Home benefit / daily care), which would silently fall back to defaults.
    try {
      if (remoteConfig.getString('GLUCOSE_FAQS').isNotEmpty == true) {
        _glucoseFaqs = (jsonDecode(remoteConfig.getString('GLUCOSE_FAQS'))
                as List<dynamic>)
            .map((item) => GlucoseFaq.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
    _vnpayIntegratedInfo = AppSettings.environment == "product"
        ? remoteConfig.getString('VNPAY_INTEGRATED_INFO')
        : remoteConfig.getString('VNPAY_INTEGRATED_INFO_DEV');
    _subscriptionPackageInfo =
        remoteConfig.getString('SUBSCRIPTION_PACKAGE_INFO');
    _benefitAtHomeInfo = remoteConfig.getString('BENEFIT_AT_HOME_INFO');
    _homeBenefitShortcuts = remoteConfig.getString('HOME_BENEFIT_SHORTCUTS');
    _homeDailyCareConfig = remoteConfig.getString('HOME_DAILY_CARE_CONFIG');
  }

  /// Re-fetches Remote Config (throttled by `minimumFetchInterval`) and
  /// refreshes only the store-version keys. Used by the force-update check on
  /// app resume. Never throws — on failure the last activated values stay.
  Future<void> refreshStoreVersions(
      {Duration timeout = const Duration(seconds: 10)}) async {
    try {
      await remoteConfig.fetchAndActivate().timeout(timeout);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
    _appStoreVersion = remoteConfig.getString('APP_STORE_VERSION');
    _playStoreVersion = remoteConfig.getString('PLAY_STORE_VERSION');
  }
}
