import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoManager {
  VideoManager({
    required String? url,
    this.onExitFullScreen,
    this.onCompleted,
  }) {
    initController(url: url);
  }
  BetterPlayerController? _controller;
  final VoidCallback? onExitFullScreen;
  final VoidCallback? onCompleted;
  bool finishedVideo = false;
  bool hasVideo = false;

  BetterPlayerController? get controller => hasVideo ? _controller : null;

  void refreshUrl({required String? url}) {
    finishedVideo = false;
    if (url == null) {
      _controller?.pause();
      _controller?.seekTo(Duration.zero);

      hasVideo = false;
      return;
    } else {
      hasVideo = true;
    }

    if (_controller == null) {
      initController(url: url);
    }

    if (url != _controller?.betterPlayerDataSource?.url) {
      _controller?.setupDataSource(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
        ),
      );
      _controller?.retryDataSource();
      _controller?.setControlsAlwaysVisible(true);
    }
  }

  void initController({required String? url}) {
    if (url?.isNotEmpty != true) return;
    final BetterPlayerController newController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoDispose: false,
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url!,
      ),
    )..addEventsListener(
        (event) async {
          if (event.betterPlayerEventType ==
                  BetterPlayerEventType.hideFullscreen &&
              onExitFullScreen != null) {
            await Future.delayed(const Duration(seconds: 1));
            onExitFullScreen!.call();
          }
        },
      );
    newController.videoPlayerController?.addListener(() {
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
