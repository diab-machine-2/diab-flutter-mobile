import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class VideoManager {
  BetterPlayerController? controller;
  List<VideoSourceData> sourceList = [];
  int currentSourceIndex = 0;
  bool isCompleted = false;
  final VoidCallback? onDone;
  bool isLocked = false;
  Timer? _timer;
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

  VideoManager.fromExerciseData(BuildContext context, ExerciseMovementResponseData exerciseData, {this.onDone, this.onCompleteVideo}) {
    sourceList.clear();

    for (final ExerciseMovementResponseDataSections? data in exerciseData.sections ?? []) {
      sourceList.add(VideoSourceData(url: data?.videoUrl ?? '', loopTimes: data?.replayTime ?? 1, exerciseCategoryId: data?.exerciseCategoryId ?? ''));
    }

    if (sourceList.isEmpty) {
      sourceList.add(VideoSourceData(url: exerciseData.videoUrl ?? '', loopTimes: 1, exerciseCategoryId: ''));
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
      );
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        sourceList[currentSourceIndex].url,
      );
      newController.setupDataSource(betterPlayerDataSource);

      newController.videoPlayerController?.addListener(() async {
        if (Platform.isIOS) {
          if ((newController.videoPlayerController!.value.position.inMilliseconds) ==
              newController.videoPlayerController!.value.duration!.inMilliseconds) {
        //    Message.showToastMessage(context, 'Paused');
            await newController.pause();
          }
        }
        if (!isLocked &&
            newController.videoPlayerController?.value != null &&
            !newController.videoPlayerController!.value.isPlaying &&
            newController.videoPlayerController!.value.initialized &&
            (newController.videoPlayerController!.value.duration ==
                newController.videoPlayerController!.value.position)) {
          _startTimer();
          // if (Platform.isIOS) {
          //   Message.showToastMessage(context, 'Paused1');
          //   await this.controller?.pause();
          // }
          await loopVideo();
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

  void dispose() {
    this.controller?.dispose(forceDispose: true);
  }
}

class VideoSourceData {
  VideoSourceData({required this.url, required this.loopTimes, required this.exerciseCategoryId});
  final String url;
  int loopTimes;
  String exerciseCategoryId;
}
