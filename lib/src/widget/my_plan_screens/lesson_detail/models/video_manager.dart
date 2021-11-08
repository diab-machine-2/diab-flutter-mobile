import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoManager {
  VideoManager({
    required List<String> urls,
    this.onExitFullScreen,
    this.onAllFinished,
  }) {
    refreshSourceList(urls: urls);
  }
  final List<BetterPlayerController> controllerList = [];
  final VoidCallback? onExitFullScreen;
  final VoidCallback? onAllFinished;
  List<bool> finishedVideo = [];
  bool isAllFinished = false;

  int urlsLength = -1;

  BetterPlayerController getController(index) => controllerList[index];

  int get videoAmount =>
      urlsLength == -1 ? this.controllerList.length : urlsLength;

  void refreshSourceList({required List<String> urls}) {
    urlsLength = urls.length;
    finishedVideo = List.generate(urls.length, (index) => false);

    if (urls.length > controllerList.length) {
      for (int urlIndex = controllerList.length;
          urlIndex < urls.length;
          urlIndex++) {
        addNewController(
          url: urls[urlIndex],
          onExitFullScreen: onExitFullScreen,
        );
      }
    }

    if (urls.length < controllerList.length) {
      for (int index = urls.length; index < controllerList.length; index++) {
        controllerList[index].stopPreCache(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            controllerList[index].betterPlayerDataSource?.url ?? '',
          ),
        );
      }
    }

    for (int index = 0; index < urls.length; index++) {
      if (urls[index] != controllerList[index].betterPlayerDataSource?.url) {
        controllerList[index].setupDataSource(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            urls[index],
          ),
        );
        controllerList[index].retryDataSource();
        controllerList[index].setControlsAlwaysVisible(true);
      }
    }
  }

  void addNewController({required String url, VoidCallback? onExitFullScreen}) {
    final int urlIndex = controllerList.length;
    final BetterPlayerController newController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoDispose: false,
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
      ),
    )..addEventsListener(
        (event) async {
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            pauseVideoExcept(urlIndex);
          }
          if (event.betterPlayerEventType ==
                  BetterPlayerEventType.hideFullscreen &&
              onExitFullScreen != null) {
            await Future.delayed(const Duration(seconds: 1));
            onExitFullScreen.call();
          }
        },
      );
    newController.videoPlayerController?.addListener(() {
      if (newController.videoPlayerController?.value != null &&
          !newController.videoPlayerController!.value.isPlaying &&
          newController.videoPlayerController!.value.initialized &&
          (newController.videoPlayerController!.value.duration ==
              newController.videoPlayerController!.value.position)) {
        onFinished(urlIndex);
      }
    });
    controllerList.add(newController);
  }

  void onFinished(int index) {
    finishedVideo[index] = true;
    for (final bool isFinised in finishedVideo) {
      if (!isFinised) return;
    }
    isAllFinished = true;
    onAllFinished?.call();
  }

  void pauseVideoExcept(int exceptIndex) {
    for (int index = 0; index < this.controllerList.length; index++) {
      if (index == exceptIndex) continue;
      this.controllerList[index].pause();
    }
  }

  void disposeAllVideo() {
    for (final BetterPlayerController controller in this.controllerList) {
      controller.dispose(forceDispose: true);
    }
  }
}
