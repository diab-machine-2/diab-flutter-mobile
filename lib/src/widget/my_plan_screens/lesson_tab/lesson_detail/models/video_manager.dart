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

      // Create data source with iOS-optimized headers
      Map<String, String> headers = {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
        'Accept':
            'video/webm,video/ogg,video/*;q=0.9,application/ogg;q=0.7,audio/*;q=0.6,*/*;q=0.5',
        'Accept-Encoding': 'identity;q=1, *;q=0',
        'Accept-Language': 'en-US,en;q=0.9',
        'Connection': 'keep-alive',
      };

      // Add range header only for non-HLS content
      if (url != null && !url.contains('.m3u8')) {
        headers['Range'] = 'bytes=0-';
      }

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        // Use HLS for .m3u8 URLs, otherwise use network
        url?.contains('.m3u8') == true
            ? BetterPlayerDataSourceType.network
            : BetterPlayerDataSourceType.network,
        url!,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: videoTitle ?? 'DiaB Lesson',
          author: videoArtist ?? 'DiaB',
          imageUrl: videoThumbnail,
        ),
        headers: headers,
        // Configure caching differently for different content types
        cacheConfiguration: url.contains('.m3u8')
            ? null // Don't cache HLS streams
            : BetterPlayerCacheConfiguration(
                useCache: true,
                preCacheSize: 5 * 1024 * 1024, // Reduced to 5MB for iOS
                maxCacheSize: 50 * 1024 * 1024, // Reduced to 50MB for iOS
                maxCacheFileSize:
                    25 * 1024 * 1024, // Reduced to 25MB per file for iOS
              ),
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

      // Wait longer for metadata to load, especially for larger files
      await Future.delayed(Duration(milliseconds: 2000));

      // Force a small seek to trigger metadata loading
      try {
        if (!_isDisposed &&
            newController.videoPlayerController?.value.initialized == true) {
          await newController.seekTo(Duration(milliseconds: 1));
          await Future.delayed(Duration(milliseconds: 500));
          await newController.seekTo(Duration.zero);
        }
      } catch (e) {
        print('[VIDEO] Error during seek workaround: $e');
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
      if (Platform.isIOS && value.position != null && value.duration != null) {
        final position = value.position!.inMilliseconds;
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
          value.duration != null &&
          value.position != null) {
        final duration = value.duration!;
        final position = value.position!;

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
    if (_isDisposed) return;
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
