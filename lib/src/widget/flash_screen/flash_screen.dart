import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/deep_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/bloc/nipro/nipro_bloc.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/service/docosan_client.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/service/country_service.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../modal/user/secure.dart';
import '../../model/repository/app_repository.dart';
import '../../model/service/app_client.dart';

class FlashScreenController extends StatefulWidget {
  @override
  _FlashScreenControllerState createState() => _FlashScreenControllerState();
}

class _FlashScreenControllerState extends State<FlashScreenController> {
  bool isNavigateToStepList = false;
  SecureModel? secureModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
    _getCountryCode();
    print('[ROUTE] _FlashScreenControllerState initState');
  }

  void _initStateAsync() async {
    // Setup deeplink handlers
    BranchioLinkConfig.instance.setUpHandleDeepLink();
    // await DynamicLinkConfig.instance.setUpHandleDeepLink();

    // Initialize app configurations
    await getSecuredModel();
    await getVersion();
    BlocProvider.of<NiproBloc>(context).add(NiproEventFetchSavedDevice());

    // Continue with normal app initialization
    await getData(context);
  }

  void _getCountryCode() async {
    try {
      final countryCode = await CountryService().getCountryCode();
      AppSettings.setCountryCode(countryCode);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  Future<void> getVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform()
          .timeout(const Duration(seconds: 3));
      AppSettings.version = packageInfo.version;
      AppSettings.buildNumber = packageInfo.buildNumber;
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  Future<void> getSecuredModel() async {
    // Fallback available immediately so AppSettings.secureModel is never
    // null while the real fetch is in flight. No screen needs this
    // synchronously on splash — only Profile and the welcome-package screen
    // read it, both post-Home/Login, and Profile already re-fetches on its
    // own if this hasn't landed by the time it's opened
    // (profile_controller.dart's `if (AppSettings.secureModel == null)`).
    secureModel = SecureModel(
      email: "lienhe@diab.com.vn",
      support: "Supporter",
      hotline: "0768 07 07 27",
      security: "security",
      environment: "production",
    );
    AppSettings.secureModel = secureModel;
    _fetchInfoSecureInBackground();

    // getAppVersion() used to be awaited here too, but its result was never
    // read anywhere (it got unconditionally overwritten before use) — the
    // network call (and the store-version check inside it) was pure dead
    // weight on every cold start, removed entirely.
    await AppSettings.saveEnvironment(Const.ENVIRONMENT_DEFAULT);
    AppSettings.environment = Const.ENVIRONMENT_DEFAULT;
    appClient = AppClient().getAppClient();
    docosanClient = DocosanClient().getDocosanClient();
  }

  // Fire-and-forget: splash must not block on this (see getSecuredModel).
  void _fetchInfoSecureInBackground() async {
    try {
      final model = await UserClient()
          .fetchInfoSecure()
          .timeout(const Duration(seconds: 8));
      if (model != null) {
        secureModel = model;
        AppSettings.secureModel = model;
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  Future<void> getData(BuildContext context) async {
    String? sharedCode;
    try {
      sharedCode = await DeepLinkConfig.instance
          .getInitLink()
          .timeout(const Duration(seconds: 3));
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      sharedCode = null;
    }
    try {
      await FirebaseRemoteSetting.instance
          .init()
          .timeout(const Duration(seconds: 10));
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }

    try {
      final token = await AppSettings.getToken();
      final clickedBranchLink = await AppSettings.getClickedBranchLink();
      print('flashScreen clickedBranchLink: $clickedBranchLink');
      AppSettings.environment = await AppSettings.getEnvironment();

      // Mark splash screen initialization as complete
      AppSettings.setSplashScreenInitDone(true);
      _isInitialized = true;

      // Normal flow - navigate to tabbar or login screen
      if (token.isNotEmpty) {
        var user = await UserClient().getUserPreferences();
        AppSettings.userInfo = user;
        if (user == null) {
          if (!isNavigateToStepList) {
            Message.showToastMessage(context,
                R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
            AppSettings.logout(isNavigateToStepListScreen: false);
            await Navigator.pushReplacementNamed(
              context,
              NavigatorName.step_list,
              arguments: sharedCode,
            );
            isNavigateToStepList = true;

            // After navigating to step_list, check if we need to navigate to login screen
            await handleDeeplinkLogin();
          }
        } else {
          await AppSettings.loadPrecachedHome().catchError((e) {
            TrackingManager.recordError(e, null);
          });

          // Navigate to tabbar (TabbarController will handle any pending deeplinks)
          await Navigator.pushReplacementNamed(
            context,
            NavigatorName.tabbar,
            arguments: sharedCode,
          );
        }
      } else {
        await Navigator.pushReplacementNamed(
          context,
          NavigatorName.step_list,
          arguments: sharedCode,
        );

        // After navigating to step_list, check if we need to navigate to login screen
        await handleDeeplinkLogin();
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      UserModel? userInfo = AppSettings.userInfo;
      Map<String, dynamic> errorData = {
        'phone': userInfo?.phoneNumber,
        'file': 'lib/src/widget/flash_screen/flash_screen.dart',
        'type': 'error from mobile code (try-catch)',
        'error_string': e.toString(),
      };
      LoginClient().appLogs(errorData);
      if (!isNavigateToStepList) {
        Message.showToastMessage(context,
            R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
        AppSettings.logout();
        isNavigateToStepList = true;

        // After navigating to step_list, check if we need to navigate to login screen
        await handleDeeplinkLogin();
      }
    }
  }

  handleDeeplinkLogin() async {
    // After navigating to step_list, check if we need to navigate to login screen
    if (BranchioLinkConfig.instance.hasPendingLoginDeeplink) {
      await Future.delayed(Duration(milliseconds: 100));
      await BranchioLinkConfig.instance.executeLoginDeeplinkNavigation();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppMediaQuery().init(context);
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: FittedBox(
        child: Image.asset(R.drawable.splash),
        fit: BoxFit.fill,
      ),
    );
  }
}
