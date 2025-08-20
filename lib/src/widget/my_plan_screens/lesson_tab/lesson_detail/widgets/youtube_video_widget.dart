import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:medical/res/R.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoWidget extends StatefulWidget {
  final String videoUrl;
  final Function({dynamic meta}) onEnded;
  final Function({dynamic meta}) onPlay;
  final String? videoTitle;
  final String? videoArtist;
  final String? videoThumbnail;

  const YoutubeVideoWidget({
    Key? key,
    required this.videoUrl,
    required this.onEnded,
    required this.onPlay,
    this.videoTitle,
    this.videoArtist,
    this.videoThumbnail,
  }) : super(key: key);

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget>
    with WidgetsBindingObserver {
  BetterPlayerController? _controller;
  bool _isInitializing = true;
  bool _hasError = false;
  dynamic _videoMetaData;
  YoutubeExplode? _youtubeExplode;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  @override
  void didUpdateWidget(YoutubeVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _refreshVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    _youtubeExplode?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        debugPrint('YouTube: App paused/inactive - keeping audio playing');
        break;
      case AppLifecycleState.resumed:
        debugPrint('YouTube: App resumed');
        break;
      case AppLifecycleState.detached:
        _controller?.pause();
        break;
      default:
        break;
    }
  }

  void _disposeController() {
    try {
      _controller?.dispose(forceDispose: true);
      _controller = null;
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }

  Future<void> _refreshVideo() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _hasError = false;
      });
    }

    _disposeController();
    await _initializePlayer();

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;

    try {
      if (widget.videoUrl.isEmpty) {
        throw Exception('No YouTube video URL provided');
      }

      _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (_videoId == null) {
        throw Exception('Invalid YouTube URL: ${widget.videoUrl}');
      }

      debugPrint('Initializing YouTube video with URL: ${widget.videoUrl}');

      // Use aggressive caching and reduced quality for faster loading
      await _initializeFastBetterPlayer();
    } catch (e) {
      debugPrint('Error initializing YouTube video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _initializeFastBetterPlayer() async {
    _youtubeExplode = YoutubeExplode();

    try {
      // Enhanced URL handling for different YouTube formats
      final videoId = _extractVideoId(widget.videoUrl);
      if (videoId == null) {
        throw Exception(
            'Could not extract video ID from URL: ${widget.videoUrl}');
      }

      debugPrint('Extracted video ID: $videoId from URL: ${widget.videoUrl}');

      // Get video metadata first
      final videoMetadata = await _youtubeExplode!.videos
          .get(videoId)
          .timeout(const Duration(seconds: 5));
      final videoDuration = videoMetadata.duration?.inSeconds;
      debugPrint(
          'Video metadata duration: ${videoDuration ?? 'unknown'} seconds');

      // Get stream manifest with multiple client attempts for better compatibility
      StreamManifest? streamManifest;
      Exception? lastError;

      // Try different YouTube clients for better stream availability
      final clientConfigs = [
        [YoutubeApiClient.android],
        [YoutubeApiClient.ios],
        [YoutubeApiClient.android, YoutubeApiClient.ios],
      ];

      for (final clients in clientConfigs) {
        try {
          debugPrint(
              'Trying YouTube clients: ${clients.map((c) => c.toString()).join(', ')}');
          streamManifest = await _youtubeExplode!.videos.streamsClient
              .getManifest(
                videoId,
                ytClients: clients,
              )
              .timeout(const Duration(seconds: 5));
          debugPrint(
              'Successfully got stream manifest with ${clients.length} client(s)');
          break;
        } catch (e) {
          debugPrint('Failed with clients $clients: $e');
          lastError = e is Exception ? e : Exception(e.toString());
          continue;
        }
      }

      if (streamManifest == null) {
        throw lastError ??
            Exception(
                'Failed to get stream manifest from all client configurations');
      }

      // Enhanced stream selection with better error handling
      MuxedStreamInfo? streamInfo = _selectBestStreamRobust(streamManifest);

      if (streamInfo == null) {
        // Try to get any video stream as a fallback
        debugPrint(
            'No muxed streams found, trying video-only + audio-only combination...');
        throw Exception(
            'No suitable video stream found. Available muxed: ${streamManifest.muxed.length}, video-only: ${streamManifest.videoOnly.length}');
      }

      final streamUrl = streamInfo.url.toString();
      debugPrint(
          'Selected stream URL: ${streamUrl.substring(0, 100)}...'); // Log first 100 chars
      debugPrint(
          'Stream details: ${streamInfo.videoQualityLabel} (${streamInfo.container}) - ${streamInfo.bitrate.bitsPerSecond} bps');

      if (!mounted) return;

      _videoMetaData = {'videoId': videoId, 'duration': videoDuration};

      // Create controller with more reliable configuration
      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          handleLifecycle: false,
          allowedScreenSleep: false,
          fit: BoxFit.contain,
          aspectRatio: 16 / 9,
          autoDispose: false,
          expandToFill: false,
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: Image.asset(R.drawable.ic_thumbnail1, fit: BoxFit.cover),
            ),
          ),
          showPlaceholderUntilPlay: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          systemOverlaysAfterFullScreen: [
            SystemUiOverlay.top,
            SystemUiOverlay.bottom,
          ],
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
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          streamUrl,
          videoFormat: BetterPlayerVideoFormat.other,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: widget.videoTitle ?? 'DiaB Lesson',
            author: widget.videoArtist ?? 'DiaB',
            imageUrl: widget.videoThumbnail,
            notificationChannelName: "DiaB Media Player",
            activityName: "MainActivity",
          ),
          headers: {
            'User-Agent':
                'com.google.android.youtube/17.36.4 (Linux; U; Android 11) gzip',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate',
            'Origin': 'https://www.youtube.com',
            'Referer': 'https://www.youtube.com/watch?v=$videoId',
          },
        ),
      );

      // Enhanced event listeners for better media session control
      _controller!.addEventsListener((event) async {
        if (mounted) {
          switch (event.betterPlayerEventType) {
            case BetterPlayerEventType.play:
              debugPrint('Video playing - updating media session');
              widget.onPlay(meta: _videoMetaData);
              break;
            case BetterPlayerEventType.pause:
              debugPrint('Video paused - updating media session');
              break;
            case BetterPlayerEventType.finished:
              debugPrint('Video finished');
              _controller!.exitFullScreen();
              await Future.delayed(const Duration(seconds: 1));
              widget.onEnded(meta: _videoMetaData);
              break;
            case BetterPlayerEventType.initialized:
              debugPrint('Player initialized - media session should be ready');
              break;
            default:
              break;
          }
        }
      });

      // Reliable initialization process
      await _reliableInitialization();

      debugPrint(
          'YouTube BetterPlayer initialized successfully with notification support');

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Fast BetterPlayer initialization failed: $e');
      rethrow;
    }
  }

  // Enhanced video ID extraction for different YouTube URL formats
  String? _extractVideoId(String url) {
    // Handle multiple YouTube URL formats
    final patterns = [
      RegExp(
          r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/watch\?.*v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be\/([a-zA-Z0-9_-]{11})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final videoId = match.group(1);
        debugPrint(
            'Extracted video ID: $videoId using pattern: ${pattern.pattern}');
        return videoId;
      }
    }

    // Fallback to YouTube Player's method
    final fallbackId = YoutubePlayer.convertUrlToId(url);
    debugPrint('Fallback extraction result: $fallbackId');
    return fallbackId;
  }

  // More robust stream selection with detailed logging
  MuxedStreamInfo? _selectBestStreamRobust(StreamManifest manifest) {
    debugPrint('=== Stream Selection Debug ===');
    debugPrint('Total muxed streams available: ${manifest.muxed.length}');
    debugPrint('Total video-only streams: ${manifest.videoOnly.length}');
    debugPrint('Total audio-only streams: ${manifest.audioOnly.length}');

    if (manifest.muxed.isEmpty) {
      debugPrint('❌ No muxed streams available!');
      return null;
    }

    // Log all available muxed streams
    for (int i = 0; i < manifest.muxed.length; i++) {
      final stream = manifest.muxed[i];
      debugPrint(
          'Stream $i: ${stream.videoQualityLabel} (${stream.container}) - ${stream.bitrate.bitsPerSecond} bps - ${stream.size.totalMegaBytes.toStringAsFixed(1)}MB');
    }

    // Prioritize stable formats over quality
    final preferredContainers = [
      StreamContainer.mp4, // Most compatible
      StreamContainer.webM, // Fallback
    ];

    final preferredQualities = [
      VideoQuality.medium360, // Good balance
      VideoQuality.low240, // Lower quality but more stable
      VideoQuality.medium480, // Acceptable
      VideoQuality.low144, // Last resort
    ];

    // First pass: Try to find MP4 with preferred quality
    for (final quality in preferredQualities) {
      for (final container in preferredContainers) {
        final stream = manifest.muxed
            .where((info) =>
                info.container == container && info.videoQuality == quality)
            .firstOrNull;
        if (stream != null) {
          debugPrint(
              '✅ Selected: ${stream.videoQualityLabel} (${stream.container}) - PREFERRED');
          return stream;
        }
      }
    }

    // Second pass: Any MP4 stream
    final mp4Stream = manifest.muxed
        .where((info) => info.container == StreamContainer.mp4)
        .firstOrNull;
    if (mp4Stream != null) {
      debugPrint('✅ Selected MP4 fallback: ${mp4Stream.videoQualityLabel}');
      return mp4Stream;
    }

    // Third pass: Lowest bitrate stream (most likely to work)
    final sortedStreams = List<MuxedStreamInfo>.from(manifest.muxed)
      ..sort(
          (a, b) => a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond));

    if (sortedStreams.isNotEmpty) {
      final stream = sortedStreams.first;
      debugPrint(
          '✅ Selected lowest bitrate: ${stream.videoQualityLabel} (${stream.container}) - ${stream.bitrate.bitsPerSecond} bps');
      return stream;
    }

    debugPrint('❌ No suitable stream found');
    return null;
  }

  // More reliable initialization with better error handling
  Future<void> _reliableInitialization() async {
    try {
      debugPrint('Starting reliable initialization...');

      // Setup data source with timeout
      await _controller!
          .setupDataSource(_controller!.betterPlayerDataSource!)
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Setup data source timed out after 10 seconds');
        },
      );

      debugPrint('Data source setup completed');

      // Wait for controller to be ready
      int attempts = 0;
      bool isReady = false;

      while (attempts < 60 && !isReady) {
        // 60 attempts = 12 seconds
        await Future.delayed(Duration(milliseconds: 200));

        final controller = _controller?.videoPlayerController;
        if (controller != null) {
          final value = controller.value;

          if (attempts % 10 == 0) {
            // Log every 2 seconds
            debugPrint('Initialization attempt ${attempts + 1}/60:');
            debugPrint('  - Initialized: ${value.initialized}');
            debugPrint('  - Has error: ${value.hasError}');
            debugPrint('  - Error: ${value.errorDescription ?? 'none'}');
            debugPrint(
                '  - Duration: ${value.duration?.inSeconds ?? 'unknown'}s');
          }

          if (value.hasError) {
            throw Exception('Video player error: ${value.errorDescription}');
          }

          if (value.initialized &&
              value.duration != null &&
              value.duration!.inMilliseconds > 0) {
            debugPrint('✅ Player successfully initialized');
            debugPrint('  - Duration: ${value.duration!.inSeconds}s');
            debugPrint(
                '  - Video size: ${value.size?.width}x${value.size?.height}');
            isReady = true;
            break;
          }
        }

        attempts++;
        if (!mounted) return;
      }

      if (!isReady) {
        final controller = _controller?.videoPlayerController;
        if (controller?.value.hasError == true) {
          throw Exception(
              'Player initialization failed with error: ${controller!.value.errorDescription}');
        } else {
          debugPrint(
              '⚠️ Player initialization incomplete but no errors detected');
          // Continue anyway - sometimes works despite incomplete initialization
        }
      }
    } catch (e) {
      debugPrint('❌ Error in reliable initialization: $e');
      rethrow; // Let the caller handle the error
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load YouTube video',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitializing = true;
                });
                _initializePlayer();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isInitializing || _controller == null) {
      return Container(
        height: 200,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _controller!),
    );
  }
}
