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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _youtubeExplode = YoutubeExplode();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  @override
  void didUpdateWidget(YoutubeVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If URL changes, refresh like video widget does
    if (oldWidget.videoUrl != widget.videoUrl) {
      _refreshVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    _youtubeExplode?.close();
    _youtubeExplode = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Follow the same pattern as video widget
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        debugPrint('YouTube: App paused/inactive - keeping audio playing');
        // Don't pause to allow background audio playback
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

  Future<void> _refreshVideo() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _hasError = false;
        _isInitialized = false;
      });
    }

    try {
      _disposeController();
      await _initializePlayer();
    } catch (e) {
      debugPrint('Error refreshing YouTube video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
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

  Future<void> _initializePlayer() async {
    if (_isInitialized || !mounted) return;
    _isInitialized = true;

    try {
      if (widget.videoUrl.isEmpty) {
        debugPrint('No YouTube video URL provided');
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _hasError = true;
          });
        }
        return;
      }

      debugPrint('Initializing YouTube video with URL: ${widget.videoUrl}');

      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL: ${widget.videoUrl}');
      }

      // Fetch stream manifest with timeout like video widget
      final streamManifest = await Future.any([
        Future.delayed(Duration(seconds: 15)), // 15 second timeout
        _fetchStreamManifestWithRetry(videoId),
      ]);

      if (streamManifest is! StreamManifest) {
        throw Exception('Timeout fetching stream manifest');
      }

      // Fetch video metadata for duration
      final videoMetadata = await _youtubeExplode!.videos.get(videoId);
      final videoDuration = videoMetadata.duration?.inSeconds;
      debugPrint(
          'Video metadata duration: ${videoDuration ?? 'unknown'} seconds');

      // Select best available stream with better logic
      MuxedStreamInfo? streamInfo;

      // Try to find MP4 streams first, prioritizing lower quality for better compatibility
      final mp4Streams = streamManifest.muxed
          .where((info) => info.container == StreamContainer.mp4)
          .toList();

      if (mp4Streams.isNotEmpty) {
        // Sort by quality, prefer 360p or 480p for better compatibility
        mp4Streams.sort((a, b) {
          final aQuality = a.videoQuality.name;
          final bQuality = b.videoQuality.name;

          // Prefer medium quality streams for stability
          final preferredOrder = [
            'medium360',
            'medium480',
            'small240',
            'large720',
            'hd1080'
          ];
          final aIndex = preferredOrder.indexOf(aQuality);
          final bIndex = preferredOrder.indexOf(bQuality);

          if (aIndex != -1 && bIndex != -1) {
            return aIndex.compareTo(bIndex);
          } else if (aIndex != -1) {
            return -1;
          } else if (bIndex != -1) {
            return 1;
          }
          return 0;
        });

        streamInfo = mp4Streams.first;
        debugPrint('Selected MP4 stream: ${streamInfo.videoQualityLabel}');
      } else {
        // Fallback to any muxed stream
        streamInfo = streamManifest.muxed.firstOrNull;
        debugPrint(
            'No MP4 streams found, using fallback: ${streamInfo?.videoQualityLabel}');
      }

      if (streamInfo == null) {
        throw Exception('No suitable muxed stream found');
      }

      final streamUrl = streamInfo.url.toString();
      debugPrint(
          'Using muxed stream: $streamUrl (quality: ${streamInfo.videoQualityLabel}, container: ${streamInfo.container})');

      if (!mounted) return;

      _videoMetaData = {'videoId': videoId, 'duration': videoDuration};

      // Create controller with same configuration pattern as VideoManager
      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
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

      // Add event listener first (like VideoManager)
      _controller!.addEventsListener((event) async {
        await _handlePlayerEvent(event);
      });

      // Setup data source with enhanced configuration
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        streamUrl,
        videoFormat: BetterPlayerVideoFormat.other,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: widget.videoTitle ?? 'DiaB Lesson',
          author: widget.videoArtist ?? 'DiaB',
          imageUrl: widget.videoThumbnail,
        ),
        headers: {
          'User-Agent': 'diaB Video Player',
          'Accept': 'video/mp4',
          'Range': 'bytes=0-', // Help with streaming
        },
        bufferingConfiguration: BetterPlayerBufferingConfiguration(
          minBufferMs: 2000, // Reduced for faster start
          maxBufferMs: 10000, // Reduced to prevent over-buffering
          bufferForPlaybackMs: 1000,
          bufferForPlaybackAfterRebufferMs: 2000,
        ),
      );

      await _controller!.setupDataSource(betterPlayerDataSource);

      // Wait a moment for data source to settle
      await Future.delayed(Duration(milliseconds: 300));

      // Add video player listener (like VideoManager)
      _controller!.videoPlayerController?.addListener(() async {
        await _handleVideoPlayerEvents();
      });

      // Get the controller reference with timeout (like video widget)
      await Future.any([
        Future.delayed(Duration(seconds: 10)), // 10 second timeout
        _getControllerWithRetry(),
      ]);

      // Ensure video is properly initialized
      await ensureVideoInitialized();

      debugPrint('YouTube video controller initialized successfully');
    } catch (e) {
      debugPrint('Error initializing YouTube video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<StreamManifest> _fetchStreamManifestWithRetry(String videoId) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        return await _youtubeExplode!.videos.streamsClient.getManifest(
          videoId,
          ytClients: [
            YoutubeApiClient.ios,
            YoutubeApiClient.android,
          ],
        ).timeout(const Duration(seconds: 15));
      } catch (e) {
        attempts++;
        debugPrint('Stream manifest fetch attempt $attempts failed: $e');
        if (attempts >= 3) rethrow;
        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    }
    throw Exception('Failed to fetch stream manifest after 3 attempts');
  }

  Future<void> _getControllerWithRetry() async {
    int attempts = 0;
    while (attempts < 30 && _controller?.videoPlayerController == null) {
      try {
        if (_controller?.videoPlayerController != null) {
          debugPrint('Controller obtained successfully');
          break;
        }
      } catch (e) {
        debugPrint('Error getting controller (attempt ${attempts + 1}): $e');
      }
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;
    }

    if (_controller?.videoPlayerController == null) {
      throw Exception('Failed to get video controller after 30 attempts');
    }
  }

  Future<void> ensureVideoInitialized() async {
    if (_controller == null) {
      debugPrint('No player controller available');
      return;
    }

    try {
      // Enhanced initialization check with metadata validation
      int attempts = 0;
      bool isInitialized = false;
      final expectedDuration = _videoMetaData['duration'] as int?;

      debugPrint(
          'Ensuring video initialization. Expected duration: ${expectedDuration ?? 'unknown'} seconds');

      while (attempts < 100 && !isInitialized) {
        if (_controller!.videoPlayerController?.value.initialized == true) {
          final duration = _controller!.videoPlayerController!.value.duration;

          if (duration != null && duration.inMilliseconds > 0) {
            debugPrint(
                'Player duration: ${duration.inSeconds}s, Expected: ${expectedDuration ?? 'unknown'}s');

            // Validate duration against metadata
            if (expectedDuration != null) {
              final durationDiff =
                  (duration.inSeconds - expectedDuration).abs();
              final maxAllowedDiff =
                  (expectedDuration * 0.1).ceil(); // 10% tolerance

              // If duration is way off and we haven't tried much, retry
              if (durationDiff > maxAllowedDiff &&
                  durationDiff > 2 &&
                  attempts < 30) {
                debugPrint(
                    'Duration mismatch detected: ${duration.inSeconds}s vs ${expectedDuration}s (diff: ${durationDiff}s), retrying...');
                try {
                  await _controller!.retryDataSource();
                  await Future.delayed(Duration(milliseconds: 1500));
                } catch (e) {
                  debugPrint('Retry failed: $e');
                }
                attempts += 5; // Skip ahead after retry
                continue;
              }
            }

            debugPrint(
                'Video successfully initialized with duration: ${duration.inSeconds}s');
            isInitialized = true;
            break;
          } else {
            debugPrint('Duration is null or zero, attempt $attempts');
          }
        } else {
          debugPrint('Video not initialized yet, attempt $attempts');
        }

        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      // If still not initialized properly, attempt one final reload
      if (!isInitialized) {
        debugPrint(
            'Video not properly initialized after ${attempts} attempts, attempting final reload');
        try {
          await _controller!.retryDataSource();
          await Future.delayed(Duration(milliseconds: 2000));

          // Check final result
          final finalDuration =
              _controller!.videoPlayerController?.value.duration;
          debugPrint(
              'Final check - Duration: ${finalDuration?.inSeconds ?? 'unknown'}s');

          if (finalDuration != null && finalDuration.inMilliseconds > 0) {
            debugPrint('Video initialized after final retry');
          } else {
            debugPrint(
                'Final retry still shows invalid duration, but continuing');
          }
        } catch (e) {
          debugPrint('Error during final retry: $e');
          // Don't throw here, let it continue with whatever state we have
        }
      }
    } catch (e) {
      debugPrint('Error ensuring video initialization: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<void> _handlePlayerEvent(BetterPlayerEvent event) async {
    try {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        widget.onPlay(meta: _videoMetaData);
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        _controller!.exitFullScreen();
        await Future.delayed(const Duration(seconds: 1));
        widget.onEnded(meta: _videoMetaData);
      }
    } catch (e) {
      debugPrint('Error handling player event: $e');
    }
  }

  Future<void> _handleVideoPlayerEvents() async {
    try {
      if (_controller?.videoPlayerController?.value != null &&
          !_controller!.videoPlayerController!.value.isPlaying &&
          _controller!.videoPlayerController!.value.initialized) {
        Duration? duration = _controller!.videoPlayerController!.value.duration;
        Duration? position = _controller!.videoPlayerController!.value.position;

        if (duration != null &&
            position != null &&
            duration.inMilliseconds > 0) {
          // Check for completion (like VideoManager)
          if (duration == position) {
            try {
              _controller!.exitFullScreen();
              await Future.delayed(const Duration(seconds: 1));
            } catch (e) {
              debugPrint(
                  "Error exiting fullscreen on completion: ${e.toString()}");
            }
            widget.onEnded(meta: _videoMetaData);
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling video player events: $e');
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
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitializing = true;
                  _isInitialized = false;
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            color: R.color.black,
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
