import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class TrackingManager {
  // Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
  static final _kShouldTestAsyncErrorOnInit = true;

// Toggle this for testing Crashlytics in your app locally.
  static final _kTestingCrashlytics = !kDebugMode;

  static Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      // print(list[100]);
    });
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observerFirebase =
      FirebaseAnalyticsObserver(analytics: analytics);

  // Define an async function to initialize FlutterFire
  static Future<void> initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await Firebase.initializeApp();

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError!(errorDetails);
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }
}
