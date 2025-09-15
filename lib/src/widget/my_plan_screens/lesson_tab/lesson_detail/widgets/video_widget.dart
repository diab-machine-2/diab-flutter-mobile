import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoWidget extends StatefulWidget {
  VideoWidget({
    required this.url,
    required this.onComplete,
    this.onPlay,
    this.callbackByPercentVideo,
    this.percentCallbackDefault = 1,
    required this.setVideoManager,
    this.callbackEventListener,
    this.videoTitle,
    this.videoArtist,
    this.videoThumbnail,
    this.isYouTubeLink = false,
  });

  final String url;
  final VoidCallback onComplete;
  final VoidCallback? onPlay;
  final VoidCallback? callbackByPercentVideo;
  final Function(CustomPlayerEventType, Duration)? callbackEventListener;
  final double percentCallbackDefault;
  final Function(VideoManager) setVideoManager;
  final String? videoTitle;
  final String? videoArtist;
  final String? videoThumbnail;
  final bool isYouTubeLink;

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> with WidgetsBindingObserver {
  String? url;
  VideoManager? videoManager;
  bool isInitializing = true;
  BetterPlayerController? playerController;
  bool hasError = false;
  String? errorMessage;
  int retryCount = 0;
  static const int maxRetries = 1;
  bool _isDisposed = false;
  bool _isInitializing = false;

  String _getTimestamp() {
    return DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.SSS
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    url = widget.url;
    debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget.initState url=$url isYouTube=${widget.isYouTubeLink}');
    initializeVideo();
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      url = widget.url;
      retryCount = 0;
      debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget.didUpdateWidget url changed to $url');
      _cleanupAndRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget.dispose called, starting cleanup');
    _isDisposed = true;
    _cleanup();
    super.dispose();
  }

  void _cleanup() {
    try {
      debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget._cleanup begin - isInitializing: $_isInitializing');
      _isDisposed = true;
      _isInitializing = false;
      
      // Force dispose video manager first to stop any ongoing initialization
      if (videoManager != null) {
        debugPrint('[VIDEO][${_getTimestamp()}] Disposing video manager during cleanup');
        videoManager?.disposeAllVideo();
        videoManager = null;
      }
      
      // Then dispose player controller
      if (playerController?.videoPlayerController?.value.initialized == true) {
        playerController?.pause();
      }
      // Force pause even if not initialized to prevent background audio
      playerController?.pause();
      playerController?.dispose();
      playerController = null;
      
      debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget._cleanup completed');
    } catch (e) {
      debugPrint('[VIDEO][${_getTimestamp()}] Error during cleanup: $e');
      playerController?.dispose();
      videoManager?.disposeAllVideo();
      debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget._cleanup done');
    }
  }

  void _cleanupAndRefresh() {
    debugPrint('[VIDEO][${_getTimestamp()}] _cleanupAndRefresh called');
    _cleanup();
    playerController = null;
    videoManager = null;
    if (!_isDisposed) {
      _refreshVideo();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        debugPrint('App paused/inactive - keeping video audio playing');
        break;
      case AppLifecycleState.resumed:
        debugPrint('App resumed');
        if (playerController != null &&
            playerController!.videoPlayerController?.value.hasError == true) {
          _refreshVideo();
        }
        break;
      case AppLifecycleState.detached:
        if (playerController?.videoPlayerController?.value.initialized ==
            true) {
          playerController?.pause();
        }
        break;
      default:
        break;
    }
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
          '[VIDEO][${_getTimestamp()}] Processing YouTube URL: $youtubeUrl');

      var videoId = VideoId.parseVideoId(youtubeUrl);
      if (videoId == null) {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Invalid YouTube URL: $youtubeUrl');
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
            '[VIDEO][${_getTimestamp()}] Selected muxed MP4 stream: ${selectedStream.qualityLabel}, Size: ${selectedStream.size}');
        return selectedStream.url.toString();
      } else {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] No suitable streams found with video and audio');
        debugPrint('[VIDEO][${_getTimestamp()}] Available stream types:');
        debugPrint(
            '[VIDEO][${_getTimestamp()}] - HLS streams: ${streamManifest.streams.whereType<HlsVideoStreamInfo>().length}');
        debugPrint(
            '[VIDEO][${_getTimestamp()}] - Muxed streams: ${streamManifest.streams.whereType<MuxedStreamInfo>().length}');
        debugPrint(
            '[VIDEO][${_getTimestamp()}] - Video-only streams: ${streamManifest.videoOnly.length}');
        debugPrint(
            '[VIDEO][${_getTimestamp()}] - Audio-only streams: ${streamManifest.audioOnly.length}');
        var videoStream = streamManifest.video.withHighestBitrate();
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Selected video stream: ${videoStream.qualityLabel}, Size: ${videoStream.size}');
        return videoStream.url.toString();
      }

      // HLS stream handling is error-prone on iOS, so disabled for now
      // // Priority 2: HLS streams (contain both video and audio, well supported by BetterPlayer)
      // var hlsStreams = streamManifest.streams
      //     .whereType<HlsVideoStreamInfo>()
      //     .where((stream) =>
      //         stream.videoQuality != VideoQuality.low144 &&
      //         stream.videoQuality != VideoQuality.low240)
      //     .toList();

      // if (hlsStreams.isNotEmpty) {
      //   // Sort by quality (lowest acceptable quality first for faster loading)
      //   hlsStreams.sort(
      //       (a, b) => a.videoQuality.index.compareTo(b.videoQuality.index));
      //   var selectedStream = hlsStreams.first;
      //   debugPrint(
      //       '[VIDEO] Selected HLS stream: ${selectedStream.qualityLabel}');
      //   return selectedStream.url.toString();
      // }
    } catch (e) {
      debugPrint('[VIDEO][${_getTimestamp()}] Error extracting stream URL: $e');
      return null;
    } finally {
      yt.close();
    }
  }

  Future<void> _refreshVideo() async {
    debugPrint('[VIDEO][${_getTimestamp()}] _refreshVideo called - mounted: $mounted, disposed: $_isDisposed');
    if (!mounted || _isDisposed) {
      debugPrint('[VIDEO][${_getTimestamp()}] _refreshVideo aborted - not mounted or disposed');
      return;
    }

    setState(() {
      isInitializing = true;
      hasError = false;
      errorMessage = null;
    });

    await _initializeVideoWithRetry();
  }

  Future<void> initializeVideo() async {
    if (_isDisposed) {
      debugPrint('[VIDEO][${_getTimestamp()}] initializeVideo aborted - already disposed');
      return;
    }
    _isInitializing = true;
    debugPrint('[VIDEO][${_getTimestamp()}] initializeVideo started');
    await _initializeVideoWithRetry();
    _isInitializing = false;
    debugPrint('[VIDEO][${_getTimestamp()}] initializeVideo completed');
  }

  Future<void> _initializeVideoWithRetry() async {
    debugPrint('[VIDEO][${_getTimestamp()}] _initializeVideoWithRetry started - mounted: $mounted, disposed: $_isDisposed');
    if (!mounted || _isDisposed) {
      debugPrint('[VIDEO][${_getTimestamp()}] _initializeVideoWithRetry aborted - not mounted or disposed');
      return;
    }

    String? finalUrl = url;

    // Handle YouTube URLs
    if (widget.isYouTubeLink || isYouTubeLink(widget.url)) {
      try {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Detected YouTube URL, converting...');
        final mp4YoutubeUrl = await getMp4UrlFromYouTube(widget.url);
        if (mp4YoutubeUrl != null) {
          finalUrl = mp4YoutubeUrl;
          debugPrint(
              '[VIDEO][${_getTimestamp()}] YouTube URL converted successfully');
        } else {
          throw Exception('Failed to extract playable URL from YouTube');
        }
      } catch (e) {
        debugPrint('[VIDEO][${_getTimestamp()}] YouTube processing failed: $e');
        if (mounted && !_isDisposed) {
          setState(() {
            isInitializing = false;
            hasError = true;
            errorMessage = 'Failed to process YouTube link: $e';
          });
        }
        return;
      }
    }

    if (finalUrl == null || finalUrl.isEmpty) {
      debugPrint('[VIDEO][${_getTimestamp()}] No video URL provided');
      if (mounted && !_isDisposed) {
        setState(() {
          isInitializing = false;
          hasError = true;
          errorMessage = 'No video URL provided';
        });
      }
      return;
    }

    // Update the working URL
    url = finalUrl;

    // // Validate URL
    // final isValidUrl = await _validateVideoUrl(finalUrl);
    // if (!isValidUrl) {
    //   if (mounted) {
    //     setState(() {
    //       isInitializing = false;
    //       hasError = true;
    //       errorMessage = 'Invalid video URL or unsupported format';
    //     });
    //   }
    //   return;
    // }

    // Attempt initialization with retry logic
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      debugPrint('[VIDEO][${_getTimestamp()}] Initialization attempt ${attempt + 1}/${maxRetries + 1} - mounted: $mounted, disposed: $_isDisposed');
      if (!mounted || _isDisposed) {
        debugPrint('[VIDEO][${_getTimestamp()}] Initialization attempt ${attempt + 1} aborted - not mounted or disposed');
        return;
      }

      try {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Initialization attempt ${attempt + 1}/${maxRetries + 1} for URL: $finalUrl');

        if (_isDisposed) {
          debugPrint('[VIDEO][${_getTimestamp()}] Initialization attempt ${attempt + 1} aborted - disposed before video manager creation');
          return;
        }
        
        await _createVideoManager();

        if (_isDisposed) {
          debugPrint('[VIDEO][${_getTimestamp()}] Initialization attempt ${attempt + 1} aborted - disposed after video manager creation');
          return;
        }

        // Wait for controller with shorter timeout
        playerController = await _getControllerWithRetry();

        if (playerController == null) {
          throw Exception('Failed to get video controller');
        }

        if (_isDisposed) {
          debugPrint('[VIDEO][${_getTimestamp()}] Initialization attempt ${attempt + 1} aborted - disposed after controller creation');
          return;
        }

        // Check video readiness with shorter timeout
        final isReady = await _waitForVideoReady(maxAttempts: 30);

        if (isReady) {
          debugPrint(
              '[VIDEO][${_getTimestamp()}] Video successfully initialized on attempt ${attempt + 1}');
          if (mounted && !_isDisposed) {
            setState(() {
              isInitializing = false;
              hasError = false;
            });
          }
          return;
        } else {
          throw Exception('Video metadata failed to load (duration = 0)');
        }
      } catch (e) {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Attempt ${attempt + 1} failed: $e');

        if (attempt < maxRetries) {
          // Clean up failed attempt
          _cleanup();
          playerController = null;
          videoManager = null;

          // Shorter wait before retry
          await Future.delayed(Duration(seconds: 1));
          debugPrint('[VIDEO][${_getTimestamp()}] Retrying in 1 second...');
        } else {
          // Final attempt failed
          if (mounted && !_isDisposed) {
            setState(() {
              isInitializing = false;
              hasError = true;
              errorMessage =
                  'Video failed to load after ${maxRetries + 1} attempts. This may be due to network issues or incompatible video format.';
            });
          }
        }
      }
    }
  }

  Future<void> _createVideoManager() async {
    debugPrint('[VIDEO][${_getTimestamp()}] _createVideoManager called - mounted: $mounted, disposed: $_isDisposed, isInitializing: $_isInitializing');
    if (!mounted || _isDisposed) {
      debugPrint('[VIDEO][${_getTimestamp()}] _createVideoManager aborted - not mounted or disposed');
      return;
    }
    
    // Prevent multiple video managers from being created
    if (videoManager != null) {
      debugPrint('[VIDEO][${_getTimestamp()}] Video manager already exists, disposing old one');
      videoManager?.disposeAllVideo();
      videoManager = null;
    }
    
    // Double check disposal state before creating new manager
    if (_isDisposed) {
      debugPrint('[VIDEO][${_getTimestamp()}] _createVideoManager aborted - disposed during cleanup');
      return;
    }
    
    videoManager = VideoManager(
      url: url,
      callbackEventListener: widget.callbackEventListener,
      onPlay: widget.onPlay,
      callbackByPercentVideo: widget.callbackByPercentVideo,
      percentCallbackDefault: widget.percentCallbackDefault,
      onCompleted: widget.onComplete,
      placeHolder: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                R.drawable.ic_thumbnail1,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
      onExitFullScreen: () {},
      videoTitle: widget.videoTitle,
      videoArtist: widget.videoArtist,
      videoThumbnail: widget.videoThumbnail,
    );

    if (mounted && !_isDisposed) {
      debugPrint('[VIDEO][${_getTimestamp()}] Setting video manager in parent');
      widget.setVideoManager(videoManager!);
    } else {
      debugPrint('[VIDEO][${_getTimestamp()}] Not setting video manager - not mounted or disposed');
    }
  }

  Future<BetterPlayerController?> _getControllerWithRetry() async {
    int attempts = 0;
    while (attempts < 20 && mounted && !_isDisposed) {
      try {
        final controller = await videoManager?.controller;
        if (controller != null) {
          debugPrint(
              '[VIDEO][${_getTimestamp()}] Controller obtained successfully');
          return controller;
        }
      } catch (e) {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Error getting controller (attempt ${attempts + 1}): $e');
      }
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;
    }
    return null;
  }

  Future<bool> _waitForVideoReady({int maxAttempts = 30}) async {
    if (playerController == null || _isDisposed) return false;

    int attempts = 0;

    while (attempts < maxAttempts && mounted && !_isDisposed) {
      try {
        final videoPlayerController = playerController!.videoPlayerController;
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Video player controller: ${videoPlayerController?.value}');
        if (videoPlayerController?.value.hasError == true) {
          debugPrint(
              '[VIDEO][${_getTimestamp()}] Video player has error: ${videoPlayerController?.value.errorDescription}');
          throw Exception(
              'Video player error: ${videoPlayerController?.value.errorDescription}');
        }

        if (videoPlayerController?.value.initialized == true) {
          final duration = videoPlayerController!.value.duration;

          // Check if we have valid duration and size
          if (duration != null && duration.inMilliseconds > 0) {
            debugPrint(
                '[VIDEO][${_getTimestamp()}] Video ready - Duration: ${duration.inSeconds}s');
            return true;
          }

          debugPrint(
              '[VIDEO][${_getTimestamp()}] Video initialized but not ready - Duration: ${duration?.inMilliseconds}ms');

          await playerController?.retryDataSource();
        }
      } catch (e) {
        debugPrint(
            '[VIDEO][${_getTimestamp()}] Error checking video readiness: $e');
        throw e;
      }

      await Future.delayed(Duration(milliseconds: 200));
      attempts++;
    }

    debugPrint(
        '[VIDEO][${_getTimestamp()}] Video not ready after $maxAttempts attempts');
    return false;
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage ?? 'Failed to load video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (retryCount >= maxRetries) GapH(16),
            if (retryCount >= maxRetries)
              ElevatedButton(
                onPressed: retryCount < maxRetries
                    ? () {
                        if (mounted && !_isDisposed) {
                          retryCount++;
                          setState(() {
                            hasError = false;
                            isInitializing = true;
                            errorMessage = null;
                          });
                          initializeVideo();
                        }
                      }
                    : null,
                child: Text(R.string.retry.tr()),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget.build -> error: $errorMessage');
      return _buildErrorWidget();
    }

    if (isInitializing || playerController == null) {
      debugPrint('[VIDEO][${_getTimestamp()}] VideoWidget.build -> loading... (playerController is ${playerController == null ? 'null' : 'not null'})');
      return Container(
        height: 200,
        color: R.color.backgroundColorNew,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: R.color.greenGradientBottom,
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: playerController!),
    );
  }
}
