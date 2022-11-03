import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';

class VideoManager {
  VideoManager({
    required String? url,
    this.onCompleted,
    this.placeHolder,
    this.onExitFullScreen,
    this.callbackByPercentVideo,
    this.percentCallbackDefault = 1,
  }) {
    initController(url: url);
  }
  BetterPlayerController? _controller;
  final double percentCallbackDefault;
  final VoidCallback? callbackByPercentVideo;
  final VoidCallback? onExitFullScreen;
  final VoidCallback? onCompleted;
  Widget? placeHolder;
  bool finishedVideo = false;
  bool hasVideo = false;

  StreamController<bool> _placeholderStreamController =
      StreamController.broadcast();

  BetterPlayerController? get controller => hasVideo ? _controller : null;

  Future<void> refreshUrl({required String? url}) async {
    finishedVideo = false;
    if (url == null) {
      await _controller?.seekTo(Duration.zero);
      await _controller?.pause();

      hasVideo = false;
      return;
    } else {
      hasVideo = true;
    }

    if (_controller == null) {
      initController(url: url);
    }

    _controller?.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
      ),
    );
    _controller?.retryDataSource();
    _controller?.setControlsAlwaysVisible(true);
    await Future.delayed(Duration.zero);
    await _controller?.seekTo(Duration.zero);
    await _controller?.pause();
  }

  void initController({required String? url}) {
    if (url?.isNotEmpty != true) return;
    final BetterPlayerController newController = BetterPlayerController(
      BetterPlayerConfiguration(
        placeholder: placeHolder == null
            ? Container(color: R.color.black)
            : _buildVideoPlaceholder(),
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
      // betterPlayerDataSource: BetterPlayerDataSource(
      //   BetterPlayerDataSourceType.network,
      //   url!,
      //  ),
    )..addEventsListener(
        (event) async {
          if (event.betterPlayerEventType ==
                  BetterPlayerEventType.hideFullscreen &&
              onExitFullScreen != null) {
            await Future.delayed(const Duration(seconds: 1));
            onExitFullScreen!.call();
          }
          // print('event.betterPlayerEventType = ${event.betterPlayerEventType}');
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            _placeholderStreamController.add(true);
          }
        },
      );

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url!,
    );
    newController.setupDataSource(betterPlayerDataSource);
    print("newController.videoPlayerController: ${newController.videoPlayerController}");
    newController.videoPlayerController?.addListener(() async {
      if (Platform.isIOS) {
        if ((newController
                .videoPlayerController!.value.position.inMilliseconds) ==
            newController
                .videoPlayerController!.value.duration?.inMilliseconds) {
          if (Platform.isIOS) {
            try {
              await newController.pause();
            } catch (e) {
              print("${e.toString()}");
            }
          }
          print('newController.pause()');
        }
      }
      if (newController.videoPlayerController?.value != null &&
          !newController.videoPlayerController!.value.isPlaying &&
          newController.videoPlayerController!.value.initialized) {
        Duration? duration =
            newController.videoPlayerController!.value.duration;
        Duration? position =
            newController.videoPlayerController!.value.position;

        // WHEN COMPLETE VIDEO
        if (duration == position) {
          onCompleted?.call();
          finishedVideo = true;
        }

        // CALLBACK BY PERCENT VIDEO
        if (callbackByPercentVideo != null &&
            (duration != null &&
                position.inSeconds / duration.inSeconds >=
                    percentCallbackDefault)) {
          callbackByPercentVideo!.call();
        }

        // if (duration != null && duration.inSeconds / position.inSeconds <= 2) {
        //   onCompleted?.call();
        //   finishedVideo = true;
        // }
      }
    });

    hasVideo = true;
    _controller = newController;
  }

  Widget _buildVideoPlaceholder() {
    return StreamBuilder<bool>(
      stream: _placeholderStreamController.stream,
      builder: (context, snapshot) {
        return snapshot.data ?? false
            ? Container(color: R.color.black)
            : placeHolder!;
      },
    );
  }

  void stopCache() {
    _controller?.stopPreCache(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _controller?.betterPlayerDataSource?.url ?? '',
      ),
    );
  }

  void disposeAllVideo() {
    _placeholderStreamController.close();
    this._controller?.dispose(forceDispose: true);
  }
}
