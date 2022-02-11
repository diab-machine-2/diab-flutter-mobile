import 'dart:async';
import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/res/R.dart';

class VideoManager {
  BetterPlayerController? controller;
  List<VideoSourceData> sourceList = [];
  int currentSourceIndex = 0;
  bool isCompleted = false;
  final VoidCallback? onDone;
  bool isLocked = false;
  Timer? _timer;

  _startTimer() {
    _stopTimer();
    isLocked = true;
    _timer = Timer(const Duration(seconds: 1), () {
      isLocked = false;
    });
  }

  _stopTimer() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
    }
  }

  VideoManager.fromExerciseData(ExerciseMovementResponseData exerciseData, {this.onDone}) {
    sourceList.clear();

    for (final ExerciseMovementResponseDataSections? data in exerciseData.sections ?? []) {
      sourceList.add(VideoSourceData(url: data?.videoUrl ?? '', loopTimes: data?.replayTime ?? 1));
    }

    if (sourceList.isEmpty) {
      sourceList.add(VideoSourceData(url: exerciseData.videoUrl ?? '', loopTimes: 1));
    }

    if (sourceList.isNotEmpty) {
      this.controller = BetterPlayerController(
        const BetterPlayerConfiguration(
          placeholder: Image.asset(R.drawable.ic_thumbnail1, fit: BoxFit.fill),
          showPlaceholderUntilPlay: true,
          aspectRatio: 16 / 9,
          autoDispose: false,
          expandToFill: false,
          allowedScreenSleep: false,
          fit: BoxFit.fitHeight,
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        ),
      );
      var betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        sourceList[currentSourceIndex].url,
      );
      this.controller!.setupDataSource(betterPlayerDataSource);

      this.controller?.videoPlayerController?.addListener(() {
        if (!isLocked &&
            this.controller?.videoPlayerController?.value != null &&
            !this.controller!.videoPlayerController!.value.isPlaying &&
            this.controller!.videoPlayerController!.value.initialized &&
            (this.controller!.videoPlayerController!.value.duration ==
                this.controller!.videoPlayerController!.value.position)) {
          _startTimer();
          loopVideo();
        }
      });
    }
  }

  lock() {}

  void playNextVideo() {
    if (currentSourceIndex + 1 >= sourceList.length) {
      isCompleted = true;
      this.controller?.pause();
      onDone?.call();
      return;
    }
    currentSourceIndex += 1;
    this.controller?.setupDataSource(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            sourceList[currentSourceIndex].url,
          ),
        );
    this.controller?.retryDataSource();
    this.controller?.setControlsAlwaysVisible(true);
  }

  void loopVideo() {
    final int newLoopTimes = sourceList[currentSourceIndex].loopTimes - 1;
    if (newLoopTimes > 0) {
      sourceList[currentSourceIndex].loopTimes = newLoopTimes;
      this.controller?.seekTo(Duration.zero);
    } else {
      playNextVideo();
    }
  }

  void dispose() {
    this.controller?.dispose(forceDispose: true);
  }
}

class VideoSourceData {
  VideoSourceData({required this.url, required this.loopTimes});
  final String url;
  int loopTimes;
}
