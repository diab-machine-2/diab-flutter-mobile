import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

class VideoManager {
  BetterPlayerController? controller;
  List<VideoSourceData> sourceList = [];
  int currentSourceIndex = 0;
  bool isCompleted = false;
  final VoidCallback? onDone;
  bool isLocked = false;
  Timer? _timer;
  Duration? videoDuration;
  int currentMillisecond = 0;
  CustomPlayerEventType? currentEventState;
  final Function(CustomPlayerEventType, Duration)? callbackEventListener;
  final Function(String, int)? onCompleteVideo;

  int count = 0;

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

  Future<void> ensureVideoInitialized() async {
    // Add a safety check to ensure video is properly initialized
    if (controller != null) {
      // Wait for up to 3 seconds for the video to initialize properly
      int attempts = 0;
      while (attempts < 30) {
        if (controller!.videoPlayerController?.value.duration != null &&
            controller!.videoPlayerController!.value.duration!.inMilliseconds >
                0) {
          debugPrint(
              '[EXERCISE] Video successfully initialized with duration: ${controller!.videoPlayerController!.value.duration!.inSeconds}s');
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      // If still not initialized properly, attempt to reload
      if (controller!.videoPlayerController?.value.duration == null ||
          controller!.videoPlayerController!.value.duration!.inMilliseconds <=
              0) {
        debugPrint(
            '[EXERCISE] Video not properly initialized, attempting reload');
        await controller!.retryDataSource();
      }
    }
  }

  bool isYoutubeUrl() {
    if (currentSourceIndex >= sourceList.length ||
        sourceList[currentSourceIndex].url.isEmpty) {
      return false;
    }

    final url = sourceList[currentSourceIndex].url;
    debugPrint('[EXERCISE] Checking URL type: $url');

    RegExp youtubeRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$',
      caseSensitive: false,
    );
    return youtubeRegExp.hasMatch(url);
  }

  VideoManager.fromExerciseData(
    BuildContext context,
    ExerciseMovementResponseData exerciseData, {
    this.callbackEventListener,
    this.onDone,
    this.onCompleteVideo,
  }) {
    sourceList.clear();

    for (final ExerciseMovementResponseDataSections? data
        in exerciseData.sections ?? []) {
      sourceList.add(VideoSourceData(
          url: data?.videoUrl ?? '',
          loopTimes: data?.replayTime ?? 1,
          exerciseCategoryId: data?.exerciseCategoryId ?? ''));
    }

    if (sourceList.isEmpty) {
      sourceList.add(VideoSourceData(
          url: exerciseData.videoUrl ?? '',
          loopTimes: 1,
          exerciseCategoryId: ''));
    }

    if (sourceList.isNotEmpty) {
      final BetterPlayerController newController = BetterPlayerController(
        BetterPlayerConfiguration(
          placeholder: Image.asset(R.drawable.ic_thumbnail1, fit: BoxFit.fill),
          showPlaceholderUntilPlay: true,
          aspectRatio: 16 / 9,
          autoDispose: false,
          expandToFill: false,
          allowedScreenSleep: false,
          fit: BoxFit.fitHeight,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        ),
      )..addEventsListener((event) async {
          if (currentEventState == null &&
              event.betterPlayerEventType == BetterPlayerEventType.play &&
              !isCompleted) {
            checkCallbackEventListener(CustomPlayerEventType.videoPlay);
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.play &&
              isCompleted) {
            checkCallbackEventListener(CustomPlayerEventType.videoReplay);
            isCompleted = false;
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
            checkCallbackEventListener(CustomPlayerEventType.videoPause);
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.progress &&
              controller != null) {
            currentMillisecond = controller!
                .videoPlayerController!.value.position.inMilliseconds;
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
            if (currentMillisecond >
                controller!
                    .videoPlayerController!.value.position.inMilliseconds) {
              checkCallbackEventListener(CustomPlayerEventType.videoPrevious);
            } else {
              checkCallbackEventListener(CustomPlayerEventType.videoFoward);
            }
          }
        });
      print(
          '[EXERCISE] video manager init from exercise data url: ${sourceList[currentSourceIndex].url}');
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        sourceList[currentSourceIndex].url,
      );
      newController.setupDataSource(betterPlayerDataSource);

      newController.videoPlayerController?.addListener(() async {
        // Wait until the video is properly initialized with a valid duration
        if (newController.videoPlayerController?.value.duration != null &&
            newController
                    .videoPlayerController!.value.duration!.inMilliseconds >
                0) {
          // Update videoDuration only if it's not set or if the current value is invalid
          if (videoDuration == null || videoDuration!.inMilliseconds <= 0) {
            videoDuration = newController.videoPlayerController!.value.duration;
            debugPrint(
                '[EXERCISE] Video duration set: ${videoDuration?.inSeconds} seconds');
          }

          // Get current values
          Duration? duration =
              newController.videoPlayerController!.value.duration;
          Duration? position =
              newController.videoPlayerController!.value.position;

          // Only process completion logic if we have valid duration and position
          if (!isLocked &&
              duration != null &&
              position != null &&
              duration.inMilliseconds > 0 &&
              !newController.videoPlayerController!.value.isPlaying &&
              newController.videoPlayerController!.value.initialized) {
            // Check if video is within 500ms of completion or past completion
            // This tolerance helps with iOS timing issues
            bool isAtEnd =
                duration.inMilliseconds - position.inMilliseconds <= 500;

            if (isAtEnd) {
              debugPrint(
                  '[EXERCISE] Video reached end: position=${position.inSeconds}s, duration=${duration.inSeconds}s');
              checkCallbackEventListener(CustomPlayerEventType.videoCompleted);
              isCompleted = true;
              _startTimer();
            }
          }
        }
      });
      this.controller = newController;
    }
  }

  lock() {}

  Future playNextVideo() async {
    await Future.delayed(Duration(milliseconds: 600));
    if (currentSourceIndex + 1 >= sourceList.length) {
      isCompleted = true;
      await this.controller?.pause();
      onDone?.call();
      return;
    }
    await this.controller?.seekTo(Duration.zero);
    currentSourceIndex += 1;
    var dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      sourceList[currentSourceIndex].url,
    );
    this.controller?.setupDataSource(dataSource);
    await this.controller?.retryDataSource();
    await this.controller?.seekTo(Duration.zero);
    await this.controller?.play();
    this.controller?.setControlsAlwaysVisible(true);
  }

  Future loopVideo() async {
    final int newLoopTimes = sourceList[currentSourceIndex].loopTimes - 1;
    if (newLoopTimes > 0) {
      sourceList[currentSourceIndex].loopTimes = newLoopTimes;
      await this.controller?.seekTo(Duration.zero);
      await this.controller?.play();
    } else {
      await playNextVideo();
    }
  }

  checkCallbackEventListener(CustomPlayerEventType type) {
    if ((callbackEventListener != null &&
            currentEventState != type &&
            isCompleted == false) ||
        type == CustomPlayerEventType.videoReplay) {
      currentEventState = type;
      callbackEventListener!(type, videoDuration ?? Duration.zero);
    }
  }

  void dispose() {
    this.controller?.dispose(forceDispose: true);
    debugPrint('[EXERCISE] video manager controller disposed');
  }
}

class VideoSourceData {
  VideoSourceData(
      {required this.url,
      required this.loopTimes,
      required this.exerciseCategoryId});
  final String url;
  int loopTimes;
  String exerciseCategoryId;
}
