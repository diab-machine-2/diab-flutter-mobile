import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/service/lesson_playback_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.vbhc.diab/lesson_playback');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<String> calls;

  setUp(() {
    calls = [];
    LessonPlaybackService.debugReset();
    LessonPlaybackService.debugIsAndroidOverride = true;
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    LessonPlaybackService.debugIsAndroidOverride = null;
    LessonPlaybackService.debugReset();
  });

  test('stop issued while start is in flight ends with a native stop',
      () async {
    final startGate = Completer<bool>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'start') return startGate.future;
      return true;
    });

    final start = LessonPlaybackService.start(title: 'Lesson');
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['start']); // native start pending
    final stop = LessonPlaybackService.stop();
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['start']); // stop waits for the start to resolve

    startGate.complete(true);
    await Future.wait([start, stop]);

    expect(calls, ['start', 'stop']);
  });

  test('failed native start does not block the next start', () async {
    var startResult = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return call.method == 'start' ? startResult : true;
    });

    await LessonPlaybackService.start();
    startResult = true;
    await LessonPlaybackService.start();
    await LessonPlaybackService.stop();

    expect(calls, ['start', 'start', 'stop']);
  });

  test('PlatformException on start is swallowed and next start retries',
      () async {
    var fail = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'start' && fail) {
        throw PlatformException(code: 'x');
      }
      return true;
    });

    await LessonPlaybackService.start();
    fail = false;
    await LessonPlaybackService.start();

    expect(calls, ['start', 'start']);
  });

  test('repeated start/stop only calls native on state changes', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });

    await LessonPlaybackService.stop(); // nothing running
    await LessonPlaybackService.start();
    await LessonPlaybackService.start();
    await LessonPlaybackService.stop();
    await LessonPlaybackService.stop();

    expect(calls, ['start', 'stop']);
  });

  test('rapid play/pause toggles end stopped', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return true;
    });

    final futures = <Future<void>>[];
    for (var i = 0; i < 5; i++) {
      futures.add(LessonPlaybackService.start());
      await Future<void>.delayed(const Duration(milliseconds: 2));
      futures.add(LessonPlaybackService.stop());
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    await Future.wait(futures);

    expect(calls, isNotEmpty);
    expect(calls.last, 'stop');
    expect(calls.where((c) => c == 'start').length,
        calls.where((c) => c == 'stop').length);
  });

  test('start+stop in the same tick never reaches native', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });

    await Future.wait(
        [LessonPlaybackService.start(), LessonPlaybackService.stop()]);

    expect(calls, isEmpty);
  });

  test('no-op off Android', () async {
    LessonPlaybackService.debugIsAndroidOverride = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });

    await LessonPlaybackService.start();
    await LessonPlaybackService.stop();

    expect(calls, isEmpty);
  });
}
