import 'dart:async';

import 'package:just_audio/just_audio.dart' as JustAudio;
import 'package:audioplayers/audioplayers.dart';
import 'package:medical/src/utils/date_utils.dart';

class AudioController {
  AudioController({
    required this.url,
    this.currentState = PlayerState.STOPPED,
    this.currentTime = Duration.zero,
    this.totalTime = Duration.zero,
  }) {
    audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    audioPlayer.onPlayerStateChanged.listen((event) {
      this.currentState = event;
      onChanged.sink.add(audioData);
    });
    audioPlayer.onDurationChanged.listen((event) {
      this.totalTime = event;
      onChanged.sink.add(audioData);
    });
    audioPlayer.onAudioPositionChanged.listen((event) {
      this.currentTime = event;
      onChanged.sink.add(audioData);
    });
    audioPlayer.onPlayerError.listen((event) {});
  }
  String url;
  PlayerState currentState;
  Duration currentTime;
  Duration totalTime;
  late AudioPlayer audioPlayer;
  final StreamController<AudioData> onChanged = StreamController<AudioData>.broadcast();

  AudioData get audioData => AudioData(
        isPlaying: currentState == PlayerState.PLAYING,
        currentTime: currentTime,
        totalTime: totalTime,
      );

  Future<void> changeUrl(String newUrl) async {
    url = newUrl;
    currentTime = Duration.zero;
    totalTime = Duration.zero;
    play(volume: 0);
    await Future.delayed(const Duration(seconds: 1));
    pause();
    audioPlayer.seek(Duration.zero);
    int secondsDuration = await audioPlayer.getDuration();
    if (secondsDuration == 0) {
      var duration = await JustAudio.AudioPlayer().setUrl(newUrl);
      if (duration != null) {
        secondsDuration = duration.inSeconds * 1000;
      }
    }
    totalTime = Duration(seconds: secondsDuration ~/ 1000);
    onChanged.sink.add(audioData);
  }

  void togglePlay() {
    if (currentState == PlayerState.PLAYING) {
      pause();
    } else {
      play();
    }
  }

  void play({double volume = 1}) {
    audioPlayer.play(url, position: currentTime, volume: volume);
  }

  void pause() => audioPlayer.pause();

  void stop() => audioPlayer.stop();

  void seekTo(double newPosition) {
    audioPlayer.seek(Duration(milliseconds: newPosition.round()));
  }

  void dispose() {
    stop();
    audioPlayer.dispose();
  }
}

class AudioData {
  AudioData({
    required this.isPlaying,
    required this.currentTime,
    required this.totalTime,
  });
  bool isPlaying;
  Duration currentTime;
  Duration totalTime;

  double get position {
    if (totalTime.inMilliseconds == 0) return 0.0;
    final double position = currentTime.inMilliseconds / totalTime.inMilliseconds;
    if (position < 0) return 0.0;
    if (position > 1) return 1.0;
    return position;
  }

  String get timeText {
    return '${DateUtil.formatDuration(currentTime)} / ${DateUtil.formatDuration(totalTime)}';
  }
}
