import 'dart:async';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'; // Add this import

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
  final VoidCallback? onExitFullScreen;
  bool hasPlayed = false;
  bool finishedVideo = false;
  bool callbackByPercentVideoSuccess = false;
  StreamController<bool> _placeholderStreamController =
      StreamController.broadcast();

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

  String _getTimestamp() {
    return DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.SSS
  }

  bool isYouTubeLink(String? url) {
    if (url == null || url.isEmpty) return false;
    final RegExp youtubeRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/',
      caseSensitive: false,
    );
    return youtubeRegex.hasMatch(url);
  }

  Future<String?> getMp4UrlFromYouTube(String youtubeUrl) async {
    var yt = YoutubeExplode();
    try {
      debugPrint(
          '[EXERCISE][${_getTimestamp()}] Processing YouTube URL: $youtubeUrl');

      var videoId = VideoId.parseVideoId(youtubeUrl);
      if (videoId == null) {
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] Invalid YouTube URL: $youtubeUrl');
        return null;
      }

      // YoutubeApiClient.ios is getting m3u8 streams -> cannot open with current player
      var ytClients = [YoutubeApiClient.android];

      var streamManifest = await yt.videos.streamsClient
          .getManifest(videoId, ytClients: ytClients);

      // Priority 1: Muxed MP4 streams (contain both video and audio)
      var muxedStreams = streamManifest.muxed.toList();

      if (muxedStreams.isNotEmpty) {
        var selectedStream = muxedStreams.first;
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] Selected muxed MP4 stream: ${selectedStream.qualityLabel}, Size: ${selectedStream.size}');
        return selectedStream.url.toString();
      } else {
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] No suitable streams found with video and audio');
        debugPrint('[EXERCISE][${_getTimestamp()}] Available stream types:');
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] - HLS streams: ${streamManifest.streams.whereType<HlsVideoStreamInfo>().length}');
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] - Muxed streams: ${streamManifest.streams.whereType<MuxedStreamInfo>().length}');
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] - Video-only streams: ${streamManifest.videoOnly.length}');
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] - Audio-only streams: ${streamManifest.audioOnly.length}');
        var videoStream = streamManifest.video.withHighestBitrate();
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] Selected video stream: ${videoStream.qualityLabel}, Size: ${videoStream.size}');
        return videoStream.url.toString();
      }
    } catch (e) {
      debugPrint(
          '[EXERCISE][${_getTimestamp()}] Error extracting stream URL: $e');
      return null;
    } finally {
      yt.close();
    }
  }

  Future<bool> waitForVideoReady({int maxAttempts = 30}) async {
    if (controller == null) return false;

    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final videoPlayerController = controller!.videoPlayerController;
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] Video player controller: ${videoPlayerController?.value}');
        if (videoPlayerController?.value.hasError == true) {
          debugPrint(
              '[EXERCISE][${_getTimestamp()}] Video player has error: ${videoPlayerController?.value.errorDescription}');
          throw Exception(
              'Video player error: ${videoPlayerController?.value.errorDescription}');
        }

        if (videoPlayerController?.value.initialized == true) {
          final duration = videoPlayerController!.value.duration;

          // Check if we have valid duration and size
          if (duration != null && duration.inMilliseconds > 0) {
            debugPrint(
                '[EXERCISE][${_getTimestamp()}] Video ready - Duration: ${duration.inSeconds}s');
            return true;
          }

          debugPrint(
              '[EXERCISE][${_getTimestamp()}] Video initialized but not ready - Duration: ${duration?.inMilliseconds}ms');

          await controller?.retryDataSource();
        }
      } catch (e) {
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] Error checking video readiness: $e');
        throw e;
      }

      await Future.delayed(Duration(milliseconds: 200));
      attempts++;
    }

    debugPrint(
        '[EXERCISE][${_getTimestamp()}] Video not ready after $maxAttempts attempts');
    return false;
  }

  bool isYoutubeUrl() {
    if (currentSourceIndex >= sourceList.length ||
        sourceList[currentSourceIndex].url.isEmpty) {
      return false;
    }

    final url = sourceList[currentSourceIndex].url;
    return isYouTubeLink(url);
  }

  VideoManager.fromExerciseData(
    BuildContext context,
    ExerciseMovementResponseData? exerciseData, {
    this.callbackEventListener,
    this.onDone,
    this.onCompleteVideo,
    this.onExitFullScreen,
  }) {
    sourceList.clear();

    for (final ExerciseMovementResponseDataSections? data
        in exerciseData?.sections ?? []) {
      sourceList.add(VideoSourceData(
          url: data?.videoUrl ?? '',
          originalUrl: data?.videoUrl ?? '', // Store original URL
          loopTimes: data?.replayTime ?? 1,
          exerciseCategoryId: data?.exerciseCategoryId ?? ''));
    }

    if (sourceList.isEmpty) {
      sourceList.add(VideoSourceData(
          url: exerciseData?.videoUrl ?? '',
          originalUrl: exerciseData?.videoUrl ?? '', // Store original URL
          loopTimes: 1,
          exerciseCategoryId: ''));
    }

    if (sourceList.isNotEmpty &&
        sourceList[currentSourceIndex].url.isNotEmpty) {
      _initializeController(exerciseData);
    }
  }

  Future<void> _processYouTubeUrls() async {
    debugPrint(
        '[EXERCISE][${_getTimestamp()}] Processing YouTube URLs in sourceList');

    for (int i = 0; i < sourceList.length; i++) {
      final videoData = sourceList[i];

      if (isYouTubeLink(videoData.originalUrl)) {
        debugPrint(
            '[EXERCISE][${_getTimestamp()}] Converting YouTube URL at index $i: ${videoData.originalUrl}');

        try {
          final mp4Url = await getMp4UrlFromYouTube(videoData.originalUrl);
          if (mp4Url != null) {
            sourceList[i].url = mp4Url; // Update with converted URL
            debugPrint(
                '[EXERCISE][${_getTimestamp()}] Successfully converted YouTube URL at index $i');
          } else {
            debugPrint(
                '[EXERCISE][${_getTimestamp()}] Failed to convert YouTube URL at index $i');
            // Keep original URL as fallback
          }
        } catch (e) {
          debugPrint(
              '[EXERCISE][${_getTimestamp()}] Error converting YouTube URL at index $i: $e');
          // Keep original URL as fallback
        }
      }
    }
  }

  Future<void> _initializeController(
      ExerciseMovementResponseData? exerciseData) async {
    // TODO: Process YouTube URLs first 
    // Currently processYoutubeUrls make controller init after the UI build
    // Cause media player controller null -> not showing on exercise detail page (line 115)
    // await _processYouTubeUrls();

    final BetterPlayerController newController =
        BetterPlayerController(BetterPlayerConfiguration(
      placeholder: _buildVideoPlaceholder(),
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
        enableRetry: true, // Add retry capability
        progressBarPlayedColor: R.color.greenGradientBottom,
        progressBarHandleColor: R.color.greenGradientBottom,
      ),
    ))
          ..addEventsListener((event) async {
            await _handlePlayerEvent(event);
          });

    print(
        '[EXERCISE] video manager init from exercise data url: ${sourceList[currentSourceIndex].url}');

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      sourceList[currentSourceIndex].url, // This will now be the processed URL
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: exerciseData?.name ?? 'DiaB Exercise',
        author: 'DiaB',
        imageUrl: exerciseData?.image?.url ?? R.drawable.ic_app,
      ),
      videoFormat: BetterPlayerVideoFormat.other,
      headers: {
        'User-Agent': 'diaB Exercise Player',
        'Accept': '*/*',
      },
    );

    newController.setupDataSource(betterPlayerDataSource);

    newController.videoPlayerController?.addListener(() async {
      await _handleVideoPlayerEvents(newController);
    });

    this.controller = newController;
  }

  Future<void> _handlePlayerEvent(BetterPlayerEvent event) async {
    try {
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.play:
          if (finishedVideo) {
            checkCallbackEventListener(CustomPlayerEventType.videoReplay);
            finishedVideo = false;
          }
          if (!hasPlayed) {
            hasPlayed = true;
          }
          _placeholderStreamController.add(true);
          break;

        case BetterPlayerEventType.pause:
          checkCallbackEventListener(CustomPlayerEventType.videoPause);
          break;

        case BetterPlayerEventType.progress:
          if (controller?.videoPlayerController?.value != null) {
            final position = controller!.videoPlayerController!.value.position;
            currentMillisecond = position.inMilliseconds;
          }
          break;

        case BetterPlayerEventType.seekTo:
          if (controller?.videoPlayerController?.value != null) {
            final currentPosition = controller!
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

        // Add error handling for network issues
        case BetterPlayerEventType.exception:
          debugPrint(
              '[EXERCISE][${_getTimestamp()}] Player exception occurred');
          await _handleNetworkError();
          break;

        default:
          break;
      }
    } catch (e) {
      debugPrint(
          '[EXERCISE][${_getTimestamp()}] Error handling player event: $e');
    }
  }

  // Add network error handling
  Future<void> _handleNetworkError() async {
    try {
      debugPrint(
          '[EXERCISE][${_getTimestamp()}] Attempting to recover from network error');

      await Future.delayed(Duration(seconds: 2));

      if (controller?.betterPlayerDataSource?.url != null) {
        final currentPosition =
            controller?.videoPlayerController?.value.position ?? Duration.zero;

        // If it's a YouTube video, try to re-extract the URL
        if (isYouTubeLink(sourceList[currentSourceIndex].originalUrl)) {
          debugPrint(
              '[EXERCISE][${_getTimestamp()}] Re-extracting YouTube URL due to error');
          final newUrl = await getMp4UrlFromYouTube(
              sourceList[currentSourceIndex].originalUrl);
          if (newUrl != null && newUrl != sourceList[currentSourceIndex].url) {
            sourceList[currentSourceIndex].url = newUrl;

            // Create new data source with updated URL
            final dataSource = BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              newUrl,
              notificationConfiguration: BetterPlayerNotificationConfiguration(
                showNotification: true,
                title: 'DiaB Exercise',
                author: 'DiaB',
                imageUrl: R.drawable.ic_app,
              ),
            );

            await controller?.setupDataSource(dataSource);

            if (currentPosition.inSeconds > 0) {
              await controller?.seekTo(currentPosition);
            }
            return;
          }
        }

        // For regular videos or if YouTube re-extraction failed, try retry
        await controller?.retryDataSource();

        if (currentPosition.inSeconds > 0) {
          await controller?.seekTo(currentPosition);
        }
      }
    } catch (e) {
      debugPrint(
          '[EXERCISE][${_getTimestamp()}] Failed to recover from network error: $e');
    }
  }

  Future<void> _handleVideoPlayerEvents(
      BetterPlayerController newController) async {
    try {
      if (Platform.isIOS &&
          newController.videoPlayerController?.value != null) {
        final value = newController.videoPlayerController!.value;
        if (value.position.inMilliseconds == value.duration?.inMilliseconds) {
          try {
            await newController.pause();
            newController.exitFullScreen();
          } catch (e) {
            debugPrint("[EXERCISE] Error pausing on iOS: ${e.toString()}");
          }
        }
      }

      // Wait until the video is properly initialized with a valid duration
      if (newController.videoPlayerController?.value.duration != null &&
          newController.videoPlayerController!.value.duration!.inMilliseconds >
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
          bool isAtEnd =
              duration.inMilliseconds - position.inMilliseconds <= 500;
          bool isExactEnd = duration == position;

          if ((isAtEnd || isExactEnd)) {
            debugPrint(
                '[EXERCISE] Video reached end: position=${position.inSeconds}s, duration=${duration.inSeconds}s');

            try {
              if (newController.isFullScreen) {
                newController.exitFullScreen();
                if (onExitFullScreen != null) {
                  await Future.delayed(const Duration(seconds: 1));
                  onExitFullScreen!.call();
                }
              }
            } catch (e) {
              debugPrint(
                  "Error exiting fullscreen on completion: ${e.toString()}");
            }

            checkCallbackEventListener(CustomPlayerEventType.videoCompleted);
            isCompleted = true;
            finishedVideo = true;
            _startTimer();

            if (onCompleteVideo != null &&
                sourceList[currentSourceIndex].exerciseCategoryId.isNotEmpty) {
              onCompleteVideo!(
                  sourceList[currentSourceIndex].exerciseCategoryId,
                  videoDuration?.inSeconds ?? 0);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[EXERCISE] Error handling video player events: $e');
    }
  }

  Widget _buildVideoPlaceholder() {
    return StreamBuilder<bool>(
      stream: _placeholderStreamController.stream,
      builder: (context, snapshot) {
        return snapshot.data ?? false
            ? Container(color: R.color.black)
            : Image.asset(R.drawable.ic_thumbnail1, fit: BoxFit.fill);
      },
    );
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

    // Process YouTube URL if needed for next video
    final nextVideoData = sourceList[currentSourceIndex];
    String videoUrl = nextVideoData.url;

    if (isYouTubeLink(nextVideoData.originalUrl) &&
        nextVideoData.url == nextVideoData.originalUrl) {
      // URL hasn't been processed yet
      try {
        final mp4Url = await getMp4UrlFromYouTube(nextVideoData.originalUrl);
        if (mp4Url != null) {
          sourceList[currentSourceIndex].url = mp4Url;
          videoUrl = mp4Url;
        }
      } catch (e) {
        debugPrint(
            '[EXERCISE] Error processing YouTube URL for next video: $e');
      }
    }

    var dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: 'DiaB Exercise',
        author: 'DiaB',
        imageUrl: R.drawable.ic_app,
      ),
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

  void checkCallbackEventListener(CustomPlayerEventType type) {
    try {
      if ((callbackEventListener != null &&
              currentEventState != type &&
              isCompleted == false) ||
          type == CustomPlayerEventType.videoReplay) {
        currentEventState = type;
        callbackEventListener!(type, videoDuration ?? Duration.zero);
      }
    } catch (e) {
      debugPrint('[EXERCISE] Error in callback event listener: $e');
    }
  }

  void stopCache() {
    try {
      controller?.stopPreCache(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          controller?.betterPlayerDataSource?.url ?? '',
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: 'DiaB Exercise',
            author: 'DiaB',
            imageUrl: R.drawable.ic_app,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[EXERCISE] Error stopping cache: $e');
    }
  }

  void dispose() {
    try {
      _placeholderStreamController.close();
      if (controller?.videoPlayerController?.value.initialized == true) {
        controller?.pause();
      }
      this.controller?.dispose(forceDispose: true);
      debugPrint('[EXERCISE] video manager controller disposed');
    } catch (e) {
      debugPrint('[EXERCISE] Error disposing video: $e');
    }
  }
}

class VideoSourceData {
  VideoSourceData({
    required this.url,
    required this.originalUrl, // Add originalUrl field
    required this.loopTimes,
    required this.exerciseCategoryId,
  });

  String url; // This will be the processed/converted URL
  final String originalUrl; // This stores the original URL (YouTube or regular)
  int loopTimes;
  String exerciseCategoryId;
}
