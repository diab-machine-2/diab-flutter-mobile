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
  bool _isLoading = true;
  bool _hasError = false;
  dynamic _videoMetaData;
  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_isInitialized || !mounted) return;
    _isInitialized = true;

    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL: ${widget.videoUrl}');
      }
      debugPrint('Video URL: ${widget.videoUrl}, Video ID: $videoId');

      // Fetch stream manifest
      final streamManifest =
          await _youtubeExplode.videos.streamsClient.getManifest(
        videoId,
        ytClients: [
          YoutubeApiClient.ios,
          YoutubeApiClient.android,
        ],
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Timed out fetching stream manifest');
      });

      // Fetch video metadata for duration
      final videoMetadata = await _youtubeExplode.videos.get(videoId);
      final videoDuration = videoMetadata.duration?.inSeconds;
      debugPrint(
          'Video metadata duration: ${videoDuration ?? 'unknown'} seconds');

      // Select best available stream
      final streamInfo = streamManifest.muxed
              .where((info) => info.container == StreamContainer.mp4)
              .firstOrNull ??
          streamManifest.muxed.first;
      if (streamInfo == null) {
        throw Exception('No suitable muxed stream found');
      }
      final streamUrl = streamInfo.url.toString();
      debugPrint(
          'Using muxed stream: $streamUrl (quality: ${streamInfo.videoQualityLabel})');

      _videoMetaData = {'videoId': videoId, 'duration': videoDuration};

      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          handleLifecycle: true,
          allowedScreenSleep: false,
          fit: BoxFit.contain,
          aspectRatio: 16 / 9,
          autoDispose: false,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          systemOverlaysAfterFullScreen: [
            SystemUiOverlay.top,
            SystemUiOverlay.bottom,
          ],
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
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: Image.asset(
                R.drawable.ic_thumbnail1,
                fit: BoxFit.cover,
              ),
            ),
          ),
          showPlaceholderUntilPlay: true,
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          streamUrl,
          videoFormat: BetterPlayerVideoFormat.other,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: widget.videoTitle ?? 'DiaB Lesson',
            author: widget.videoArtist ?? 'DiaB',
            imageUrl: widget.videoThumbnail ?? R.drawable.ic_app,
          ),
          headers: {
            'User-Agent': 'diaB Video Player',
            'Accept': 'video/mp4',
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

      // Setup data source and wait for it to be ready
      await _controller!.setupDataSource(_controller!.betterPlayerDataSource!);

      // Give the controller a moment to settle before ensuring initialization
      await Future.delayed(Duration(milliseconds: 500));

      // Ensure video is properly initialized with duration
      await ensureVideoInitialized(videoDuration);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing YouTube video: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> ensureVideoInitialized(int? metadataDurationSeconds) async {
    if (_controller == null) {
      debugPrint('No player controller available');
      return;
    }

    try {
      // Wait for up to 15 seconds for the video to initialize properly
      int attempts = 0;
      bool isInitialized = false;
      final metadataDuration = metadataDurationSeconds != null
          ? Duration(seconds: metadataDurationSeconds)
          : null;

      while (attempts < 150 && !isInitialized) {
        if (_controller!.videoPlayerController?.value.initialized == true) {
          final duration = _controller!.videoPlayerController!.value.duration;

          if (duration != null && duration.inMilliseconds > 0) {
            // Basic validation - just ensure we have a reasonable duration
            if (metadataDuration != null) {
              // If duration is too short or way off from metadata, retry
              if (duration.inSeconds < 1 ||
                  (duration.inSeconds < metadataDuration.inSeconds * 0.5 &&
                      attempts < 50)) {
                debugPrint(
                    'Duration seems invalid: ${duration.inSeconds}s vs expected: ${metadataDuration.inSeconds}s, retrying...');
                await _controller!.retryDataSource();
                await Future.delayed(Duration(milliseconds: 1000));
                attempts += 10; // Skip ahead after retry
                continue;
              }
            }

            debugPrint(
                'Video successfully initialized with duration: ${duration.inSeconds}s');
            isInitialized = true;
            break;
          }
        }

        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      // If still not initialized, attempt one final reload
      if (!isInitialized) {
        debugPrint('Video not properly initialized, attempting final reload');
        try {
          await _controller!.retryDataSource();
          await Future.delayed(Duration(milliseconds: 2000));

          // Accept whatever duration we get after final retry
          final finalDuration =
              _controller!.videoPlayerController?.value.duration;
          if (finalDuration != null && finalDuration.inMilliseconds > 0) {
            debugPrint(
                'Video initialized after final retry with duration: ${finalDuration.inSeconds}s');
          } else {
            throw Exception('Failed to initialize video with valid duration');
          }
        } catch (e) {
          debugPrint('Error during final retry: $e');
          throw e;
        }
      }
    } catch (e) {
      debugPrint('Error ensuring video initialization: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      rethrow;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
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

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose(forceDispose: true);
    _youtubeExplode.close();
    _isInitialized = false;
    super.dispose();
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
            Text(
              'Failed to load YouTube video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _isInitialized = false;
                });
                await _initializePlayer();
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

    if (_isLoading || _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _controller!),
    );
  }
}
