import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:health/health.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/model/localization/localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'src/service/medicine_service.dart';
import 'src/utils/app_log.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // logger.i('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // logger.i(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    Console.log('onError', error);
  }
}

// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

// Future<void> _ensureScreenSize(SingletonFlutterWindow window) async {
//   return window.viewConfiguration.geometry.isEmpty
//       ? Future.delayed(
//           const Duration(milliseconds: 10), () => _ensureScreenSize(window))
//       : Future.value();
// }

Future<void> main() async {
  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
  // );
//  HttpOverrides.global = new MyHttpOverrides();
  Bloc.observer = SimpleBlocObserver();
  //WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    HttpClient.enableTimelineLogging = true;
  }

  // config health
  Health().configure();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(false);

    // var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
    //     AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    // var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
    //     AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    // if (swAvailable && swInterceptAvailable) {
    //   AndroidServiceWorkerController serviceWorkerController =
    //       AndroidServiceWorkerController.instance();

    //   await serviceWorkerController
    //       .setServiceWorkerClient(AndroidServiceWorkerClient(
    //     shouldInterceptRequest: (request) async {
    //       print(request);
    //       return null;
    //     },
    //   ));
    // }
  }
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: R.color.transparent,
  //     statusBarIconBrightness: Brightness.dark,
  //     statusBarBrightness: Brightness.light));
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);
  //await initializeDateFormatting('vi_VN');
  try {
    await TrackingManager.initializeFlutterFire();
  } catch (e, s) {
    debugPrint('TrackingManager.initializeFlutterFire failed: $e\n$s');
  }

  try {
    await TrackingManager.initializeMixpanel();
  } catch (e, s) {
    debugPrint('TrackingManager.initializeMixpanel failed: $e\n$s');
  }
  // final window = widgetsBinding.window;
  // await _ensureScreenSize(window);
  await EasyLocalization.ensureInitialized();
  // Note: Firebase.initializeApp() is already called in initializeFlutterFire()

  try {
    await FlutterBranchSdk.init(enableLogging: false, disableTracking: false);
  } catch (e) {
    debugPrint('FlutterBranchSdk.init failed: $e');
  }

  try {
    await RevenueCatService.initialize();
  } catch (e) {
    debugPrint('RevenueCatService.initialize failed: $e');
  }

  // tz.initializeTimeZones();
  // final timeZoneName = await FlutterTimezone.getLocalTimezone();
  // final location = tz.getLocation(timeZoneName);
  // tz.setLocalLocation(location);

  // await MedicineScheduleService().init();

  // var zoom = ZoomVideoSdk();
  // InitConfig initConfig = InitConfig(
  //   domain: "zoom.us",
  //   enableLog: true,
  // );
  // zoom.initSdk(initConfig);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(Localization.getLocalizationWidget(app: App()));
  });
}
