import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';

void main() {
  late List<String> log;

  setUp(() {
    log = [];
    PlaybackKeepAlive.debugReset();
    PlaybackKeepAlive.onActivate = (title) => log.add('on:$title');
    PlaybackKeepAlive.onDeactivate = () => log.add('off');
  });

  tearDown(PlaybackKeepAlive.debugReset);

  test('released only when the last holder lets go', () {
    PlaybackKeepAlive.acquire('a');
    PlaybackKeepAlive.acquire('b');
    expect(PlaybackKeepAlive.activeCount, 2);

    PlaybackKeepAlive.release();
    expect(PlaybackKeepAlive.activeCount, 1);
    expect(log, ['on:a', 'on:b']);

    PlaybackKeepAlive.release();
    expect(PlaybackKeepAlive.activeCount, 0);
    expect(log, ['on:a', 'on:b', 'off']);
  });

  test('extra release never goes negative or re-deactivates', () {
    PlaybackKeepAlive.release();
    expect(PlaybackKeepAlive.activeCount, 0);
    expect(log, isEmpty);

    PlaybackKeepAlive.acquire(null);
    PlaybackKeepAlive.release();
    PlaybackKeepAlive.release();
    expect(PlaybackKeepAlive.activeCount, 0);
    expect(log, ['on:null', 'off']);
  });

  test('refresh re-applies only while held', () {
    PlaybackKeepAlive.refresh('x');
    expect(log, isEmpty);

    PlaybackKeepAlive.acquire('x');
    PlaybackKeepAlive.refresh('x');
    expect(PlaybackKeepAlive.activeCount, 1);
    expect(log, ['on:x', 'on:x']);
  });
}
