import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/localization/localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:easy_localization/easy_localization.dart';

import 'src/utils/app_log.dart';

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

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

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
  await AppSettings.setIsSyncing(false);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
  await TrackingManager.initializeFlutterFire();
  // final window = widgetsBinding.window;
  // await _ensureScreenSize(window);
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  var zoom = ZoomVideoSdk();
  InitConfig initConfig = InitConfig(
    domain: "zoom.us",
    enableLog: true,
  );
  zoom.initSdk(initConfig);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(Localization.getLocalizationWidget(app: App()));
  });
}
