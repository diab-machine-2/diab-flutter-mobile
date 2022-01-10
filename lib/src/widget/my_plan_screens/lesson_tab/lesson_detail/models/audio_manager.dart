import 'package:flutter/material.dart';

import 'audio_data.dart';

class AudioManager {
  AudioManager({required this.url, this.onCompleted}) {
    refreshUrl(url: url);
  }

  final String? url;
  final VoidCallback? onCompleted;

  AudioController? _controller;
  bool finishedAudio = false;

  bool hasAudio = false;

  AudioController? get controller => hasAudio ? _controller : null;

  void refreshUrl({required String? url}) {
    _controller?.stop();
    finishedAudio = false;

    if (url == null) {
      _controller?.pause();
      _controller?.seekTo(0);
      hasAudio = false;
      return;
    } else {
      hasAudio = true;
    }

    if (_controller == null) {
      final AudioController newAudioController = AudioController(
        url: url,
      );
      newAudioController.audioPlayer.onPlayerStateChanged.listen((state) {});
      newAudioController.audioPlayer.onPlayerCompletion.listen((_) {
        finishedAudio = true;
        onCompleted?.call();
      });
      _controller = newAudioController;
    }

    _controller?.changeUrl(
      url,
    );
  }

  void disposeAllAudio() {
    _controller?.stop();
    _controller?.dispose();
  }
}
