import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class TrackingManager {
  // Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
  static final _kShouldTestAsyncErrorOnInit = false;
  static bool _settedUserInfo = false;

  static late Mixpanel _mixpanel;

// Toggle this for testing Crashlytics in your app locally.
  static final _kTestingCrashlytics = !kDebugMode;

  static Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      FirebaseCrashlytics.instance.crash();
    });
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observerFirebase =
      FirebaseAnalyticsObserver(analytics: analytics);

  // Define an async function to initialize FlutterFire
  static Future<void> initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await Firebase.initializeApp();

    //  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // await analytics.setAnalyticsCollectionEnabled(false);

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    await _guardUserInfoWritten();

    // Pass all uncaught errors to Crashlytics.
    Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // log error to console
      FlutterError.dumpErrorToConsole(errorDetails);
      // Forward to original handler.
      if (originalOnError != null) originalOnError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      // log error to console
      debugPrint('PlatformDispatcher.instance.onError: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  static void initializeMixpanel() async {
    _mixpanel = await Mixpanel.init("457ac685ce1ba9f3d0ab636880de4c72", trackAutomaticEvents: true);
  }

  static Future<void> _guardUserInfoWritten() async {
    if (AppSettings.userInfo != null && !_settedUserInfo) {
      await FirebaseCrashlytics.instance.setUserIdentifier(AppSettings.userInfo!.id!);
      _settedUserInfo = true;
    }
  }

  static Future<void> logError(String message) async {
    await _guardUserInfoWritten();
    return FirebaseCrashlytics.instance.log(message);
  }

  static Future<void> recordError(Object exception, StackTrace? stack, {bool fatal = false}) async {
    await _guardUserInfoWritten();
    final error = FlutterErrorDetails(
      exception: exception,
      stack: stack,
    );
    return FirebaseCrashlytics.instance.recordFlutterError(error, fatal: fatal);
  }

  static Future<void> trackEvent(String name, String screenName, {Map<String, dynamic>? params}) {
    Map<String, dynamic> parameters = {
      'screen_name': screenName,
      ...(params ?? {}),
    };

    _mixpanel.track(name, properties: parameters);

    return analytics.logEvent(name: name, parameters: parameters);
  }
}
