import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/model/localization/localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import 'src/utils/logger.dart';

class SimpleBlocObserver extends BlocObserver {

  @override
  void onChange(BlocBase bloc, Change change) {
    // super.onChange(bloc, change);
    // logger.i('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.i(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    logger.i("Error", error, stacktrace);
  }
}

Future<void> main() async {
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: R.color.transparent,
  //     statusBarIconBrightness: Brightness.dark,
  //     statusBarBrightness: Brightness.light));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //await initializeDateFormatting('vi_VN');
  await Firebase.initializeApp();
  await TrackingManager.initializeFlutterFire();

  runApp(Localization.getLocalizationWidget(app: App()));
}


