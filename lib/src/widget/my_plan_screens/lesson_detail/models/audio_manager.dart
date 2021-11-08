import 'package:audioplayers/audioplayers_api.dart';
import 'package:flutter/material.dart';

import 'audio_data.dart';

class AudioManager {
  AudioManager({required this.urls, this.onAllFinished}) {
    refreshSourceList(urls: urls);
  }

  final List<String> urls;
  final VoidCallback? onAllFinished;

  final List<AudioController> controllerList = [];
  List<bool> finishedAudio = [];

  bool isAllFinished = false;
  int urlsLength = -1;

  AudioController getController(index) => controllerList[index];

  int get audioAmount =>
      urlsLength == -1 ? this.controllerList.length : urlsLength;

  void refreshSourceList({required List<String> urls}) {
    stopAll();
    urlsLength = urls.length;
    finishedAudio = List.generate(urls.length, (index) => false);
    if (urls.length > controllerList.length) {
      for (int index = 0;
          index < urls.length - controllerList.length + 1;
          index++) {
        final AudioController newAudioController = AudioController(
          url: urls[index],
        );
        newAudioController.audioPlayer.onPlayerStateChanged.listen((state) {
          if (state == PlayerState.PLAYING) {
            pauseAudioExcept(index);
          }
        });
        newAudioController.audioPlayer.onPlayerCompletion.listen((_) {
          onFinished(index);
        });
        controllerList.add(newAudioController);
      }
    }

    for (int index = 0; index < urls.length; index++) {
      controllerList[index].changeUrl(urls[index]);
    }
  }

  void onFinished(int index) {
    finishedAudio[index] = true;
    for (final bool isFinised in finishedAudio) {
      if (!isFinised) return;
    }
    isAllFinished = true;
    onAllFinished?.call();
  }

  void pauseAudioExcept(int exceptIndex) {
    for (int index = 0; index < controllerList.length; index++) {
      if (index == exceptIndex) continue;
      controllerList[index].pause();
    }
  }

  void stopAll() {
    for (final player in controllerList) {
      player.stop();
    }
  }

  void disposeAllAudio() {
    stopAll();
    for (final player in controllerList) {
      player.dispose();
    }
  }
}
