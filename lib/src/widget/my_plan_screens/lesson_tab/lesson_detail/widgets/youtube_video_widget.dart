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
      // Parallel fetching for speed
      final futures = await Future.wait([
        // Get stream manifest with very short timeout
        _youtubeExplode!.videos.streamsClient.getManifest(
          _videoId!,
          ytClients: [
            YoutubeApiClient.android
          ], // Use only Android client for speed
        ).timeout(const Duration(seconds: 3)),
        // Get basic metadata
        _youtubeExplode!.videos
            .get(_videoId!)
            .timeout(const Duration(seconds: 3)),
      ]);

      final streamManifest = futures[0] as StreamManifest;
      final videoMetadata = futures[1] as Video;
      final videoDuration = videoMetadata.duration?.inSeconds;

      debugPrint(
          'Video metadata duration: ${videoDuration ?? 'unknown'} seconds');

      // Prioritize lower quality streams for faster loading
      MuxedStreamInfo? streamInfo;

      // Look for specific fast-loading qualities
      final preferredQualities = [
        VideoQuality.low240, // 240p - fastest
        VideoQuality.medium360, // 360p - good balance
        VideoQuality.low144, // 144p - fallback
        VideoQuality.medium480, // 480p - acceptable
      ];

      // Try to find preferred quality
      for (final quality in preferredQualities) {
        streamInfo = streamManifest.muxed
            .where((info) =>
                info.container == StreamContainer.mp4 &&
                info.videoQuality == quality)
            .firstOrNull;
        if (streamInfo != null) {
          debugPrint(
              'Found preferred quality: ${streamInfo.videoQualityLabel}');
          break;
        }
      }

      // Fallback to any MP4 stream
      streamInfo ??= streamManifest.muxed
          .where((info) => info.container == StreamContainer.mp4)
          .firstOrNull;

      // Final fallback to any stream
      streamInfo ??= streamManifest.muxed.firstOrNull;

      if (streamInfo == null) {
        throw Exception('No suitable stream found');
      }

      debugPrint(
          'Using stream: ${streamInfo.videoQualityLabel} (${streamInfo.container})');

      if (!mounted) return;

      _videoMetaData = {'videoId': _videoId, 'duration': videoDuration};

      // Create controller with optimized settings for fast loading
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
          streamInfo.url.toString(),
          videoFormat: BetterPlayerVideoFormat.other,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: widget.videoTitle ?? 'DiaB Lesson',
            author: widget.videoArtist ?? 'DiaB',
            imageUrl: widget.videoThumbnail,
            activityName: "MainActivity", // Important for Android
          ),
          headers: {
            'User-Agent': 'diaB Video Player',
            'Accept': 'video/*',
          },
        ),
      );

      // Add event listeners
      _controller!.addEventsListener((event) async {
        if (mounted) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            widget.onPlay(meta: _videoMetaData);
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            _controller!.exitFullScreen();
            await Future.delayed(const Duration(seconds: 1));
            widget.onEnded(meta: _videoMetaData);
          }
        }
      });

      // Setup data source
      await _controller!.setupDataSource(_controller!.betterPlayerDataSource!);

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
