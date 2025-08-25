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
  bool _isDisposed = false;
  bool _isPausing = false;
  Duration? videoDuration;
  int currentMillisecond = 0;
  CustomPlayerEventType? currentEventState;

  final String? videoTitle;
  final String? videoArtist;
  final String? videoThumbnail;

  StreamController<bool> _placeholderStreamController =
      StreamController.broadcast();

  Future<BetterPlayerController?> get controller async {
    // Wait for initialization to complete
    int initWaitAttempts = 0;
    while (_isInitializing && initWaitAttempts < 100) {
      await Future.delayed(Duration(milliseconds: 100));
      initWaitAttempts++;
    }

    if (_isDisposed) return null;

    // Wait for controller to be available
    int attempts = 0;
    while (_controller == null && hasVideo && attempts < 50 && !_isDisposed) {
      await Future.delayed(Duration(milliseconds: 100));
      attempts++;
    }

    return (hasVideo && !_isDisposed) ? _controller : null;
  }

  Future<void> refreshUrl({required String? url}) async {
    if (_isDisposed) return;

    finishedVideo = false;
    callbackByPercentVideoSuccess = false;
    hasPlayed = false;

    if (url == null || url.isEmpty) {
      try {
        await _controller?.seekTo(Duration.zero);
        await _controller?.pause();
      } catch (e) {
        print('[VIDEO] Error seeking/pausing during refresh: $e');
      }
      hasVideo = false;
      return;
    } else {
      hasVideo = true;
    }

    if (_controller == null) {
      await initController(url: url);
    } else {
      try {
        final dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: videoTitle ?? 'DiaB Lesson',
            author: videoArtist ?? 'DiaB',
            imageUrl: videoThumbnail,
          ),
          headers: {
            'User-Agent': 'diaB Video Player',
            'Accept': '*/*',
          },
        );

        await _controller!.setupDataSource(dataSource);
        await Future.delayed(Duration(milliseconds: 1000)); // Increased delay

        if (!_isDisposed) {
          await _controller?.seekTo(Duration.zero);
          await _controller?.pause();
        }
      } catch (e) {
        print("[VIDEO] Error refreshing URL: $e");
        // Reinitialize if refresh fails
        if (!_isDisposed) {
          await initController(url: url);
        }
      }
    }
  }

  Future<void> _initializeController({String? url}) async {
    if (_isInitializing || _isDisposed) return;

    _isInitializing = true;
    try {
      await initController(url: url);
    } catch (e) {
      print('[VIDEO] Error in _initializeController: $e');
      hasVideo = false;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> initController({required String? url}) async {
    if (_isDisposed) return;

    if (url?.isNotEmpty != true) {
      hasVideo = false;
      return;
    }

    print('[VIDEO] Initializing video controller for URL: $url');

    try {
      // Create configuration with better error handling
      final configuration = BetterPlayerConfiguration(
        placeholder: placeHolder ?? _buildDefaultPlaceholder(),
        showPlaceholderUntilPlay: true,
        aspectRatio: 16 / 9,
        autoDetectFullscreenAspectRatio: true,
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
      );

      BetterPlayerController newController =
          BetterPlayerController(configuration);

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url!,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: videoTitle ?? 'DiaB Lesson',
          author: videoArtist ?? 'DiaB',
          imageUrl: videoThumbnail,
        ),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 2000,
          maxBufferMs: 10000,
          bufferForPlaybackMs: 1000,
          bufferForPlaybackAfterRebufferMs: 2000,
        ),
        videoFormat: BetterPlayerVideoFormat.other,

        //// CacheConfiguration make ios have exception Cannot Play
        // cacheConfiguration: BetterPlayerCacheConfiguration(
        //   useCache: true,
        //   preCacheSize: 5 * 1024 * 1024, // Reduced to 5MB for iOS
        //   maxCacheSize: 50 * 1024 * 1024, // Reduced to 50MB for iOS
        //   maxCacheFileSize:
        //       25 * 1024 * 1024, // Reduced to 25MB per file for iOS
        // ),
      );

      if (_isDisposed) return;

      await newController.setupDataSource(betterPlayerDataSource);

      if (_isDisposed) {
        newController.dispose();
        return;
      }

      // Add event listeners with null checks
      newController.addEventsListener(_handlePlayerEvent);

      final videoPlayerController = newController.videoPlayerController;
      if (videoPlayerController != null) {
        videoPlayerController
            .addListener(() => _handleVideoPlayerEvents(newController));
      }

      if (!_isDisposed) {
        hasVideo = true;
        _controller = newController;
        print('[VIDEO] Video controller initialized successfully');
      } else {
        newController.dispose();
      }
    } catch (e) {
      print('[VIDEO] Error initializing video controller: $e');
      hasVideo = false;
      _controller = null;
      rethrow;
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: R.color.black,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  void removeEventListeners() {
    try {
      if (_controller != null && !_isDisposed) {
        _controller!.removeEventsListener(_handlePlayerEvent);

        final videoPlayerController = _controller!.videoPlayerController;
        if (videoPlayerController != null) {
          videoPlayerController
              .removeListener(() => _handleVideoPlayerEvents(_controller!));
        }
      }
    } catch (e) {
      print('[VIDEO] Error removing event listeners: $e');
    }
  }

  Future<void> _handlePlayerEvent(BetterPlayerEvent event) async {
    if (_isDisposed) return;

    try {
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.play:
          if (finishedVideo) {
            checkCallbackEventListener(CustomPlayerEventType.videoReplay);
            finishedVideo = false;
          }

          if (!hasPlayed && onPlay != null) {
            onPlay!();
            hasPlayed = true;
          }

          _placeholderStreamController.add(true);
          break;

        case BetterPlayerEventType.pause:
          checkCallbackEventListener(CustomPlayerEventType.videoPause);
          break;

        case BetterPlayerEventType.progress:
          if (_controller?.videoPlayerController?.value != null) {
            final position = _controller!.videoPlayerController!.value.position;
            currentMillisecond = position.inMilliseconds;
          }
          break;

        case BetterPlayerEventType.seekTo:
          if (_controller?.videoPlayerController?.value != null) {
            final currentPosition = _controller!
                .videoPlayerController!.value.position.inMilliseconds;
            if (currentMillisecond > currentPosition) {
              checkCallbackEventListener(CustomPlayerEventType.videoPrevious);
            } else {
              checkCallbackEventListener(CustomPlayerEventType.videoFoward);
            }
          }
          break;

        case BetterPlayerEventType.hideFullscreen:
          if (onExitFullScreen != null) {
            await Future.delayed(const Duration(seconds: 1));
            onExitFullScreen!.call();
          }
          break;

        default:
          break;
      }
    } catch (e) {
      print('[VIDEO] Error handling player event: $e');
    }
  }

  Future<void> _handleVideoPlayerEvents(
      BetterPlayerController controller) async {
    if (_isPausing || _isDisposed) return;

    try {
      final videoPlayerController = controller.videoPlayerController;
      if (videoPlayerController?.value == null) return;

      final value = videoPlayerController!.value;

      // Handle iOS-specific completion logic
      if (Platform.isIOS && value.duration != null) {
        final position = value.position.inMilliseconds;
        final duration = value.duration!.inMilliseconds;

        if (position >= duration && value.isPlaying) {
          _isPausing = true;
          try {
            await controller.pause();
            controller.exitFullScreen();
          } finally {
            _isPausing = false;
          }
        }
      }

      // Check if video is properly initialized
      if (value.initialized &&
          value.duration != null) {
        final duration = value.duration!;
        final position = value.position;

        // Store video duration if not already set
        if (videoDuration == null && duration.inMilliseconds > 0) {
          videoDuration = duration;
        }

        // Handle video completion
        if (duration.inMilliseconds > 0 &&
            position >= duration &&
            value.isPlaying) {
          _isPausing = true;
          try {
            checkCallbackEventListener(CustomPlayerEventType.videoCompleted);
            controller.exitFullScreen();

            if (onExitFullScreen != null) {
              await Future.delayed(const Duration(seconds: 1));
              onExitFullScreen!.call();
            }

            await controller.pause();
            onCompleted?.call();
            finishedVideo = true;
          } finally {
            _isPausing = false;
          }
        }

        // Handle percentage callback
        if (!callbackByPercentVideoSuccess &&
            callbackByPercentVideo != null &&
            duration.inMilliseconds > 0) {
          final progressPercentage = position.inSeconds / duration.inSeconds;
          if (progressPercentage >= percentCallbackDefault) {
            callbackByPercentVideo!.call();
            callbackByPercentVideoSuccess = true;
          }
        }
      }
    } catch (e) {
      print('[VIDEO] Error handling video player events: $e');
    }
  }

  void checkCallbackEventListener(CustomPlayerEventType type) {
    try {
      if (callbackEventListener != null &&
              currentEventState != type &&
              !finishedVideo ||
          type == CustomPlayerEventType.videoReplay) {
        currentEventState = type;
        callbackEventListener!(type, videoDuration ?? Duration.zero);
      }
    } catch (e) {
      print('[VIDEO] Error in callback event listener: $e');
    }
  }

  Widget _buildVideoPlaceholder() {
    return StreamBuilder<bool>(
      stream: _placeholderStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Container(color: R.color.black);
        }

        return placeHolder ?? _buildDefaultPlaceholder();
      },
    );
  }

  void stopCache() {
    try {
      if (_controller?.betterPlayerDataSource?.url != null) {
        final dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          _controller!.betterPlayerDataSource!.url,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: videoTitle ?? 'DiaB Lesson',
            author: videoArtist ?? 'DiaB',
            imageUrl: videoThumbnail,
          ),
        );

        _controller?.stopPreCache(dataSource);
      }
    } catch (e) {
      print('[VIDEO] Error stopping cache: $e');
    }
  }

  void disposeAllVideo() {
    // if (_isDisposed) return;
    _isDisposed = true;
    try {
      _placeholderStreamController.close();
      removeEventListeners();
      if (_controller?.videoPlayerController?.value.initialized == true) {
        _controller?.pause();
      }
      _controller?.dispose(forceDispose: true);
      _controller = null;
      hasVideo = false;
      _isInitializing = false;
    } catch (e) {
      print('[VIDEO] Error disposing video: $e');
    }
  }
}
