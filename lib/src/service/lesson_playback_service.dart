import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-only bridge to the native `LessonPlaybackService` (a
/// mediaPlayback-typed foreground service) that keeps the app process at
/// foreground priority while a lesson video plays, so locking the screen
/// doesn't get the activity destroyed / the process frozen and the audio cut.
///
/// No-op on other platforms. Errors are swallowed: losing the priority boost
/// must never break playback itself.
///
/// [start]/[stop] record the desired state synchronously and are serialized
/// through one Future chain, so a [stop] issued while a [start] is still in
/// flight is applied right after it (no orphaned foreground service).
class LessonPlaybackService {
  LessonPlaybackService._();

  static const MethodChannel _channel =
      MethodChannel('com.vbhc.diab/lesson_playback');

  /// What native last confirmed (service started and not stopped since).
  static bool _running = false;

  /// What callers last asked for; updated synchronously.
  static bool _wantRunning = false;

  static Future<void> _queue = Future<void>.value();

  /// Test hook: overrides the Android platform check.
  @visibleForTesting
  static bool? debugIsAndroidOverride;

  static bool get _isAndroid => debugIsAndroidOverride ?? Platform.isAndroid;

  @visibleForTesting
  static void debugReset() {
    _running = false;
    _wantRunning = false;
    _queue = Future<void>.value();
  }

  /// Starts (or keeps) the foreground service. Call only in response to a
  /// user-initiated play while the app is in the foreground.
  static Future<void> start({String? title}) {
    if (!_isAndroid) return Future<void>.value();
    _wantRunning = true;
    return _enqueue(() => _sync(title));
  }

  static Future<void> stop() {
    if (!_isAndroid) return Future<void>.value();
    _wantRunning = false;
    return _enqueue(() => _sync(null));
  }

  static Future<void> _enqueue(Future<void> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.catchError((Object _) {});
    return next;
  }

  /// Brings the native state in line with [_wantRunning]. Re-checks after the
  /// start call, since a stop may have been requested while it was pending.
  static Future<void> _sync(String? title) async {
    if (_wantRunning && !_running) {
      bool started = false;
      try {
        started =
            await _channel.invokeMethod<bool>('start', {'title': title}) ==
                true;
      } on PlatformException catch (e) {
        debugPrint('[LessonPlaybackService] start failed: $e');
      } on MissingPluginException catch (e) {
        debugPrint('[LessonPlaybackService] start unavailable: $e');
      }
      // A failed start leaves _running false so a later start is retried.
      _running = started;
    }
    if (!_wantRunning && _running) {
      _running = false;
      try {
        await _channel.invokeMethod<bool>('stop');
      } on PlatformException catch (e) {
        debugPrint('[LessonPlaybackService] stop failed: $e');
      } on MissingPluginException catch (e) {
        debugPrint('[LessonPlaybackService] stop unavailable: $e');
      }
    }
  }
}
