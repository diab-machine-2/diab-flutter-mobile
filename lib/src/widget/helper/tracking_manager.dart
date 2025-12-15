import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  static Mixpanel? _mixpanel;

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
    try {
      // Wait for Firebase to initialize
      await Firebase.initializeApp();
    } catch (e, s) {
      debugPrint(
          'TrackingManager.initializeFlutterFire Firebase init failed: $e');
      debugPrint('$s');
      return;
    }

    //  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // await analytics.setAnalyticsCollectionEnabled(false);

    try {
      if (_kTestingCrashlytics) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
      }

      await _guardUserInfoWritten();
    } catch (e, s) {
      debugPrint(
          'TrackingManager.initializeFlutterFire Crashlytics config failed: $e');
      debugPrint('$s');
    }

    // Pass all uncaught errors to Crashlytics.
    Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      try {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      } catch (e, s) {
        debugPrint(
            'TrackingManager.initializeFlutterFire recordFlutterError failed: $e');
        debugPrint('$s');
      }
      FlutterError.dumpErrorToConsole(errorDetails);
      if (originalOnError != null) originalOnError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    // IMPORTANT: Handle plugin errors gracefully to prevent cascading failures
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint(
          '[Global Error Handler] PlatformDispatcher.instance.onError: $error');
      debugPrint('[Global Error Handler] Error type: ${error.runtimeType}');

      // Don't let plugin errors break other method channels
      // MissingPluginException and PlatformException from plugins should be handled gracefully
      if (error is MissingPluginException) {
        debugPrint(
            'MissingPluginException detected - handling gracefully to prevent channel cascade failure');
        debugPrint('Missing plugin: ${error.message}');
        debugPrint('Error details: $error');
        // Log to Crashlytics but don't mark as fatal for plugin errors
        try {
          FirebaseCrashlytics.instance.recordError(
            error,
            stack,
            fatal: false, // Plugin errors are not fatal
            reason:
                'MissingPluginException - handled gracefully: ${error.message}',
          );
        } catch (e, s) {
          debugPrint(
              'TrackingManager.initializeFlutterFire recordError failed: $e');
          debugPrint('$s');
        }
        // Return true to indicate error is handled, preventing cascade
        return true;
      }

      if (error is PlatformException && error.code == 'channel-error') {
        debugPrint(
            'PlatformException(channel-error) detected - handling gracefully to prevent channel cascade failure');
        debugPrint('Channel: ${error.code}');
        debugPrint('Message: ${error.message}');
        debugPrint('Details: ${error.details}');
        debugPrint('Stack trace: $stack');

        // Try to extract channel name from stack trace if available
        String? channelName;
        if (stack != null) {
          final stackStr = stack.toString();
          // Look for common channel patterns in stack trace
          final channelPatterns = [
            'mixpanel_flutter',
            'flutter_zoom',
            'iBleSdk',
            'paymentGateway',
            'MethodChannel',
          ];
          for (final pattern in channelPatterns) {
            if (stackStr.contains(pattern)) {
              channelName = pattern;
              break;
            }
          }
        }

        debugPrint('Detected channel: ${channelName ?? "Unknown"}');

        // Log to Crashlytics but don't mark as fatal for plugin errors
        try {
          FirebaseCrashlytics.instance.recordError(
            error,
            stack,
            fatal: false, // Plugin errors are not fatal
            reason:
                'Channel error - handled gracefully: ${channelName ?? error.message ?? "Unknown channel"}',
          );
        } catch (e, s) {
          debugPrint(
              'TrackingManager.initializeFlutterFire recordError failed: $e');
          debugPrint('$s');
        }
        // Return true to indicate error is handled, preventing cascade
        return true;
      }

      // For other errors, treat as fatal
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (e, s) {
        debugPrint(
            'TrackingManager.initializeFlutterFire recordError failed: $e');
        debugPrint('$s');
      }
      return true;
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  static Future<void> initializeMixpanel() async {
    try {
      _mixpanel = await Mixpanel.init(
        "457ac685ce1ba9f3d0ab636880de4c72",
        trackAutomaticEvents: true,
      );
    } catch (e, s) {
      // Handle plugin errors gracefully - don't let them break other channels
      if (e is MissingPluginException ||
          (e is PlatformException && e.code == 'channel-error')) {
        debugPrint(
            'TrackingManager.initializeMixpanel failed (plugin not available): $e');
        debugPrint(
            'This is expected if Mixpanel plugin is not properly registered.');
        _mixpanel = null;
        // Don't rethrow - this prevents cascading failures
        return;
      }
      // For other errors, log but still don't break the app
      debugPrint('TrackingManager.initializeMixpanel failed: $e');
      debugPrint('$s');
      _mixpanel = null;
    }
  }

  static Future<void> _guardUserInfoWritten() async {
    if (AppSettings.userInfo != null && !_settedUserInfo) {
      await FirebaseCrashlytics.instance
          .setUserIdentifier(AppSettings.userInfo!.id!);
      _settedUserInfo = true;
    }
  }

  static Future<void> logError(String message) async {
    await _guardUserInfoWritten();
    return FirebaseCrashlytics.instance.log(message);
  }

  static Future<void> recordError(Object exception, StackTrace? stack,
      {bool fatal = false}) async {
    await _guardUserInfoWritten();
    final error = FlutterErrorDetails(
      exception: exception,
      stack: stack,
    );
    return FirebaseCrashlytics.instance.recordFlutterError(error, fatal: fatal);
  }

  /// Helper function to convert nullable values to non-nullable Object for Firebase Analytics
  static Map<String, Object> _convertToFirebaseParams(
      Map<String, dynamic> params) {
    final Map<String, Object> result = {};
    params.forEach((key, value) {
      // Handle null values
      if (value == null) {
        result[key] = '';
      }
      // Handle nullable String types
      else if (value is String?) {
        result[key] = value ?? '';
      }
      // Handle all other types (int, double, bool, etc.)
      else {
        result[key] = value as Object;
      }
    });
    return result;
  }

  /// Helper function to safely log events with nullable parameters
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) {
    if (parameters == null) {
      return analytics.logEvent(name: name);
    }
    Map<String, Object> firebaseParams = _convertToFirebaseParams(parameters);
    return analytics.logEvent(name: name, parameters: firebaseParams);
  }

  static Future<void> trackEvent(String name, String screenName,
      {Map<String, dynamic>? params}) {
    Map<String, dynamic> parameters = {
      'screen_name': screenName,
      ...(params ?? {}),
    };

    _mixpanel?.track(name, properties: parameters);

    // Convert Map<String, dynamic> to Map<String, Object> for Firebase Analytics
    Map<String, Object> firebaseParams = _convertToFirebaseParams(parameters);

    return analytics.logEvent(name: name, parameters: firebaseParams);
  }

  static Future<void> setUserId(String id) {
    _mixpanel?.identify(id);
    return analytics.setUserId(id: id);
  }

  static Future<void> setUserProperty(
      {required String name, required String value}) {
    _mixpanel?.getPeople().set(name, value);
    return analytics.setUserProperty(name: name, value: value);
  }
}
