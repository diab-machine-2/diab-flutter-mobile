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
    print(
        '[VIDEO] ${_getTimestamp()} - VideoManager constructor called with URL: $url');
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

  String _getTimestamp() {
    return DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.SSS
  }

  Future<BetterPlayerController?> get controller async {
    print(
        '[VIDEO] ${_getTimestamp()} - controller getter called - disposed: $_isDisposed, initializing: $_isInitializing');

    // Wait for initialization to complete
    int initWaitAttempts = 0;
    while (_isInitializing && initWaitAttempts < 100 && !_isDisposed) {
      await Future.delayed(Duration(milliseconds: 100));
      initWaitAttempts++;
    }

    if (_isDisposed) {
      print(
          '[VIDEO] ${_getTimestamp()} - controller getter aborted - disposed');
      return null;
    }

    // Wait for controller to be available
    int attempts = 0;
    while (_controller == null && hasVideo && attempts < 50 && !_isDisposed) {
      await Future.delayed(Duration(milliseconds: 100));
      attempts++;
    }

    if (_isDisposed) {
      print(
          '[VIDEO] ${_getTimestamp()} - controller getter aborted - disposed during wait');
      return null;
    }

    print(
        '[VIDEO] ${_getTimestamp()} - controller getter returning controller: ${_controller != null}');
    return (hasVideo && !_isDisposed) ? _controller : null;
  }

  Future<void> refreshUrl({required String? url}) async {
    print('[VIDEO] ${_getTimestamp()} - refreshUrl started');
    if (_isDisposed) return;

    finishedVideo = false;
    callbackByPercentVideoSuccess = false;
    hasPlayed = false;

    if (url == null || url.isEmpty) {
      try {
        await _controller?.seekTo(Duration.zero);
        await _controller?.pause();
      } catch (e) {
        print(
            '[VIDEO] ${_getTimestamp()} - Error seeking/pausing during refresh: $e');
      }
      hasVideo = false;
      return;
    } else {
      hasVideo = true;
    }

    if (_controller == null) {
      print(
          '[VIDEO] ${_getTimestamp()} - Controller is null, initializing new controller');
      await initController(url: url);
    } else {
      try {
        print(
            '[VIDEO] ${_getTimestamp()} - Setting up data source for existing controller');
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
        print(
            '[VIDEO] ${_getTimestamp()} - Data source setup completed, waiting 1 second');
        await Future.delayed(Duration(milliseconds: 1000)); // Increased delay

        if (!_isDisposed) {
          await _controller?.seekTo(Duration.zero);
          await _controller?.pause();
          print(
              '[VIDEO] ${_getTimestamp()} - Seek to zero and pause completed');
        }
      } catch (e) {
        print("[VIDEO] ${_getTimestamp()} - Error refreshing URL: $e");
        // Reinitialize if refresh fails
        if (!_isDisposed) {
          await initController(url: url);
        }
      }
    }
    print('[VIDEO] ${_getTimestamp()} - refreshUrl completed');
  }

  Future<void> _initializeController({String? url}) async {
    if (_isInitializing || _isDisposed) return;

    print('[VIDEO] ${_getTimestamp()} - _initializeController started');
    _isInitializing = true;
    try {
      await initController(url: url);
    } catch (e) {
      print('[VIDEO] ${_getTimestamp()} - Error in _initializeController: $e');
      hasVideo = false;
    } finally {
      _isInitializing = false;
      print('[VIDEO] ${_getTimestamp()} - _initializeController completed');
    }
  }

  Future<void> initController({required String? url}) async {
    print(
        '[VIDEO] ${_getTimestamp()} - initController started - disposed: $_isDisposed, url: $url');
    if (_isDisposed) {
      print(
          '[VIDEO] ${_getTimestamp()} - initController aborted - already disposed');
      return;
    }

    if (url?.isNotEmpty != true) {
      print(
          '[VIDEO] ${_getTimestamp()} - initController aborted - no URL provided');
      hasVideo = false;
      return;
    }

    print(
        '[VIDEO] ${_getTimestamp()} - Initializing video controller for URL: $url');

    BetterPlayerController? newController;
    try {
      print('[VIDEO] ${_getTimestamp()} - Creating BetterPlayer configuration');
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

      print('[VIDEO] ${_getTimestamp()} - Creating BetterPlayerController');
      if (_isDisposed) {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed during setup');
        return;
      }

      newController = BetterPlayerController(configuration);

      // Immediately check if disposed after controller creation
      if (_isDisposed) {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed after controller creation, disposing controller');
        newController.dispose();
        return;
      }

      print('[VIDEO] ${_getTimestamp()} - Creating BetterPlayerDataSource');
      if (_isDisposed) {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed during data source creation');
        newController.dispose();
        return;
      }

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url!,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: videoTitle ?? 'DiaB Lesson',
          author: videoArtist ?? 'DiaB',
          imageUrl: videoThumbnail,
        ),
        videoFormat: BetterPlayerVideoFormat.other,
      );

      if (_isDisposed) {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed before data source setup');
        newController.dispose();
        return;
      }

      print(
          '[VIDEO] ${_getTimestamp()} - Setting up data source on controller');
      await newController.setupDataSource(betterPlayerDataSource);

      // Critical check: Verify disposal state after async operation
      if (_isDisposed) {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed after data source setup, disposing controller');
        // Force pause immediately before disposing to prevent audio
        try {
          await newController.pause();
        } catch (e) {
          print('[VIDEO] ${_getTimestamp()} - Error pausing after setupDataSource: $e');
        }
        newController.dispose();
        return;
      }

      // Ensure video is paused immediately after setup to prevent auto-play
      try {
        await newController.pause();
        print('[VIDEO] ${_getTimestamp()} - Video paused after setupDataSource');
      } catch (e) {
        print('[VIDEO] ${_getTimestamp()} - Error pausing after setupDataSource: $e');
      }

      // Final disposal check before setting the controller
      if (_isDisposed) {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed before adding event listeners');
        newController.dispose();
        return;
      }

      print('[VIDEO] ${_getTimestamp()} - Adding event listeners');
      // Add event listeners with null checks
      newController.addEventsListener(_handlePlayerEvent);

      final videoPlayerController = newController.videoPlayerController;
      if (videoPlayerController != null) {
        videoPlayerController
            .addListener(() => _handleVideoPlayerEvents(newController!));
      }

      // Final check before assignment - this prevents the background audio issue
      if (!_isDisposed) {
        hasVideo = true;
        _controller = newController;
        print(
            '[VIDEO] ${_getTimestamp()} - Video controller initialized successfully');
      } else {
        print(
            '[VIDEO] ${_getTimestamp()} - initController aborted - disposed before final assignment, disposing controller');
        newController.dispose();
        return;
      }
    } catch (e) {
      print(
          '[VIDEO] ${_getTimestamp()} - Error initializing video controller: $e');
      // Dispose the controller if it was created but initialization failed
      if (newController != null) {
        try {
          newController.dispose();
        } catch (disposeError) {
          print(
              '[VIDEO] ${_getTimestamp()} - Error disposing controller during cleanup: $disposeError');
        }
      }
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
      print('[VIDEO] ${_getTimestamp()} - removeEventListeners begin');
      if (_controller != null && !_isDisposed) {
        _controller!.removeEventsListener(_handlePlayerEvent);

        final videoPlayerController = _controller!.videoPlayerController;
        if (videoPlayerController != null) {
          videoPlayerController
              .removeListener(() => _handleVideoPlayerEvents(_controller!));
        }
      }
      print('[VIDEO] ${_getTimestamp()} - removeEventListeners done');
    } catch (e) {
      print('[VIDEO] ${_getTimestamp()} - Error removing event listeners: $e');
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
      print('[VIDEO] ${_getTimestamp()} - Error handling player event: $e');
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
      if (value.initialized && value.duration != null) {
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
      print(
          '[VIDEO] ${_getTimestamp()} - Error handling video player events: $e');
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
      print(
          '[VIDEO] ${_getTimestamp()} - Error in callback event listener: $e');
    }
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
      print('[VIDEO] ${_getTimestamp()} - Error stopping cache: $e');
    }
  }

  void disposeAllVideo() {
    print('[VIDEO] ${_getTimestamp()} - disposeAllVideo started');
    _isDisposed = true;
    _isInitializing = false;
    hasVideo = false;

    try {
      print(
          '[VIDEO] ${_getTimestamp()} - disposeAllVideo closing placeholder stream');
      _placeholderStreamController.close();
      removeEventListeners();

      // Force pause immediately to stop any background audio
      try {
        _controller?.pause();
      } catch (e) {
        print('[VIDEO] ${_getTimestamp()} - Error pausing during dispose: $e');
      }

      // Additional pause check for video player controller
      if (_controller?.videoPlayerController?.value.initialized == true) {
        try {
          _controller?.videoPlayerController?.pause();
        } catch (e) {
          print(
              '[VIDEO] ${_getTimestamp()} - Error pausing video player controller: $e');
        }
      }

      // Force dispose with aggressive cleanup
      try {
        _controller?.dispose(forceDispose: true);
      } catch (e) {
        print('[VIDEO] ${_getTimestamp()} - Error disposing controller: $e');
      }

      _controller = null;
      print('[VIDEO] ${_getTimestamp()} - disposeAllVideo completed');
    } catch (e) {
      print('[VIDEO] ${_getTimestamp()} - Error disposing video: $e');
    }
  }
}
