import 'dart:async';
import 'dart:io';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

class VideoManager {
  VideoManager({
    required String? url,
    this.onPlay,
    this.onCompleted,
    this.placeHolder,
    this.onExitFullScreen,
    this.callbackByPercentVideo,
    this.callbackEventListener,
    this.percentCallbackDefault = 1,
    this.videoTitle,
    this.videoArtist,
    this.videoThumbnail,
  }) {
    _initializeController(url: url);
  }

  BetterPlayerController? _controller;
  final double percentCallbackDefault;
  final VoidCallback? onPlay;
  final Function(CustomPlayerEventType, Duration)? callbackEventListener;
  final VoidCallback? callbackByPercentVideo;
  final VoidCallback? onExitFullScreen;
  final VoidCallback? onCompleted;
  Widget? placeHolder;
  bool finishedVideo = false;
  bool callbackByPercentVideoSuccess = false;
  bool hasVideo = false;
  bool hasPlayed = false;
  bool _isInitializing = false;
  Duration? videoDuration;
  int currentMillisecond = 0;
  CustomPlayerEventType? currentEventState;

  // Media metadata
  final String? videoTitle;
  final String? videoArtist;
  final String? videoThumbnail;

  StreamController<bool> _placeholderStreamController =
      StreamController.broadcast();

  Future<BetterPlayerController?> get controller async {
    // Wait for initialization to complete
    while (_isInitializing) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Then wait for controller to be available if video exists
    int attempts = 0;
    while (_controller == null && hasVideo && attempts < 50) {
      await Future.delayed(Duration(milliseconds: 100));
      attempts++;
    }
    return hasVideo ? _controller : null;
  }

  Future<void> refreshUrl({required String? url}) async {
    finishedVideo = false;
    callbackByPercentVideoSuccess = false;
    hasPlayed = false;

    if (url == null || url.isEmpty) {
      await _controller?.seekTo(Duration.zero);
      await _controller?.pause();
      hasVideo = false;
      return;
    } else {
      hasVideo = true;
    }

    if (_controller == null) {
      await initController(url: url);
    } else {
      // Update existing controller with new URL
      try {
        _controller?.setupDataSource(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            url,
            notificationConfiguration: BetterPlayerNotificationConfiguration(
              showNotification: true,
              title: videoTitle ?? 'DiaB Lesson',
              author: videoArtist ?? 'DiaB',
              imageUrl: videoThumbnail,
            ),
          ),
        );
        await _controller?.retryDataSource();
        _controller?.setControlsAlwaysVisible(true);
        await Future.delayed(
            Duration(milliseconds: 500)); // Give time for initialization
        await _controller?.seekTo(Duration.zero);
        await _controller?.pause();
      } catch (e) {
        print("Error refreshing URL: $e");
        // Recreate controller if refresh fails
        await initController(url: url);
      }
    }
  }

  Future<void> _initializeController({String? url}) async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      await initController(url: url);
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> initController({required String? url}) async {
    if (url?.isNotEmpty != true) {
      hasVideo = false;
      return;
    }

    print('Initializing video controller for URL: $url');

    try {
      BetterPlayerController newController = BetterPlayerController(
        BetterPlayerConfiguration(
          placeholder: placeHolder == null
              ? Container(
                  color: R.color.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              : _buildVideoPlaceholder(),
          showPlaceholderUntilPlay: true,
          aspectRatio: 16 / 9,
          autoDispose: false,
          expandToFill: false,
          allowedScreenSleep: false,
          fit: BoxFit.contain,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          systemOverlaysAfterFullScreen: [
            SystemUiOverlay.top,
            SystemUiOverlay.bottom,
          ],
          handleLifecycle: false,
          autoPlay: false,
          startAt: Duration.zero,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableProgressText: true,
            enableProgressBar: true,
            enablePlayPause: true,
            enableMute: true,
            enableFullscreen: true,
            enableSubtitles: false,
            enableAudioTracks: false,
            enableOverflowMenu: true,
            enablePlaybackSpeed: true,
            progressBarPlayedColor: R.color.greenGradientBottom,
            progressBarHandleColor: R.color.greenGradientBottom,
          ),
        ),
      );

      // Add event listener
      newController.addEventsListener((event) async {
        await _handlePlayerEvent(event);
      });

      // Setup data source
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url!,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: videoTitle ?? 'DiaB Lesson',
          author: videoArtist ?? 'DiaB',
          imageUrl: videoThumbnail,
        ),
        headers: {
          'User-Agent': 'diaB Video Player',
        },
      );

      await newController.setupDataSource(betterPlayerDataSource);

      // Add video player listener
      newController.videoPlayerController?.addListener(() async {
        await _handleVideoPlayerEvents(newController);
      });

      hasVideo = true;
      _controller = newController;

      print('Video controller initialized successfully');
    } catch (e) {
      print('Error initializing video controller: $e');
      hasVideo = false;
      _controller = null;
    }
  }

  Future<void> _handlePlayerEvent(BetterPlayerEvent event) async {
    try {
      if (event.betterPlayerEventType == BetterPlayerEventType.play &&
          finishedVideo) {
        checkCallbackEventListener(CustomPlayerEventType.videoReplay);
        finishedVideo = false;
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        checkCallbackEventListener(CustomPlayerEventType.videoPause);
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.progress &&
          _controller != null) {
        currentMillisecond =
            _controller!.videoPlayerController!.value.position.inMilliseconds;
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
        if (currentMillisecond >
            _controller!.videoPlayerController!.value.position.inMilliseconds) {
          checkCallbackEventListener(CustomPlayerEventType.videoPrevious);
        } else {
          checkCallbackEventListener(CustomPlayerEventType.videoFoward);
        }
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.play &&
          !hasPlayed &&
          onPlay != null) {
        onPlay!();
        hasPlayed = true;
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen &&
          onExitFullScreen != null) {
        await Future.delayed(const Duration(seconds: 1));
        onExitFullScreen!.call();
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        _placeholderStreamController.add(true);
      }
    } catch (e) {
      print('Error handling player event: $e');
    }
  }

  Future<void> _handleVideoPlayerEvents(
      BetterPlayerController controller) async {
    try {
      // Handle iOS specific completion detection
      if (Platform.isIOS) {
        if ((controller.videoPlayerController!.value.position.inMilliseconds) ==
            controller.videoPlayerController!.value.duration?.inMilliseconds) {
          try {
            await controller.pause();
            controller.exitFullScreen();
          } catch (e) {
            print(
                "Error pausing or exiting fullscreen on iOS: ${e.toString()}");
          }
        }
      }

      if (controller.videoPlayerController?.value != null &&
          !controller.videoPlayerController!.value.isPlaying &&
          controller.videoPlayerController!.value.initialized) {
        Duration? duration = controller.videoPlayerController!.value.duration;
        Duration? position = controller.videoPlayerController!.value.position;

        // Update video duration
        if (videoDuration == null && duration != null) {
          videoDuration = duration;
        }

        if (duration != null &&
            position != null &&
            duration.inMilliseconds > 0) {
          // Check for completion
          if (duration == position) {
            checkCallbackEventListener(CustomPlayerEventType.videoCompleted);
            try {
              controller.exitFullScreen();
              if (onExitFullScreen != null) {
                await Future.delayed(const Duration(seconds: 1));
                onExitFullScreen!.call();
              }
            } catch (e) {
              print("Error exiting fullscreen on completion: ${e.toString()}");
            }
            onCompleted?.call();
            finishedVideo = true;
            
          }

          // Check for percentage callback
          if (callbackByPercentVideoSuccess == false &&
              callbackByPercentVideo != null &&
              (position.inSeconds / duration.inSeconds >=
                  percentCallbackDefault)) {
            callbackByPercentVideo!.call();
            callbackByPercentVideoSuccess = true;
          }
        }
      }
    } catch (e) {
      print('Error handling video player events: $e');
    }
  }

  checkCallbackEventListener(CustomPlayerEventType type) {
    if ((callbackEventListener != null &&
            currentEventState != type &&
            finishedVideo == false) ||
        type == CustomPlayerEventType.videoReplay) {
      currentEventState = type;
      callbackEventListener!(type, videoDuration ?? Duration.zero);
    }
  }

  Widget _buildVideoPlaceholder() {
    return StreamBuilder<bool>(
      stream: _placeholderStreamController.stream,
      builder: (context, snapshot) {
        return snapshot.data ?? false
            ? Container(color: R.color.black)
            : placeHolder ??
                Container(
                  color: R.color.black,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
      },
    );
  }

  void stopCache() {
    try {
      _controller?.stopPreCache(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          _controller?.betterPlayerDataSource?.url ?? '',
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: videoTitle ?? 'DiaB Lesson',
            author: videoArtist ?? 'DiaB',
            imageUrl: videoThumbnail,
          ),
        ),
      );
    } catch (e) {
      print('Error stopping cache: $e');
    }
  }

  void disposeAllVideo() {
    try {
      _placeholderStreamController.close();
      _controller?.dispose(forceDispose: true);
      _controller = null;
      hasVideo = false;
      _isInitializing = false;
    } catch (e) {
      print('Error disposing video: $e');
    }
  }
}
