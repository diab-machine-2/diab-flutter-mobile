import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoManager {
  VideoManager({
    required String? url,
    this.onExitFullScreen,
    this.onCompleted,
    this.placeHolder,
  }) {
    initController(url: url);
  }
  BetterPlayerController? _controller;
  final VoidCallback? onExitFullScreen;
  final VoidCallback? onCompleted;
  Widget? placeHolder;
  bool finishedVideo = false;
  bool hasVideo = false;

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
        placeholder: placeHolder == null ? Container() : placeHolder,
        showPlaceholderUntilPlay: true,
        aspectRatio: 16 / 9,
        autoDispose: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url!,
      ),
    )..addEventsListener(
        (event) async {
          if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen && onExitFullScreen != null) {
            await Future.delayed(const Duration(seconds: 1));
            onExitFullScreen!.call();
          }
        },
      );
    newController.videoPlayerController?.addListener(() async {
      if (Platform.isIOS) {
        if ((newController.videoPlayerController!.value.position.inMilliseconds) ==
            newController.videoPlayerController!.value.duration!.inMilliseconds) {
          await newController.pause();
          print('newController.pause()');
        }
      }
      if (newController.videoPlayerController?.value != null &&
          !newController.videoPlayerController!.value.isPlaying &&
          newController.videoPlayerController!.value.initialized &&
          (newController.videoPlayerController!.value.duration ==
              newController.videoPlayerController!.value.position)) {
        onCompleted?.call();
        finishedVideo = true;
      }
    });
    hasVideo = true;
    _controller = newController;
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
    this._controller?.dispose(forceDispose: true);
  }
}
