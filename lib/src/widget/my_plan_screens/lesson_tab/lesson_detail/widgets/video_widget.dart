import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
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

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> with WidgetsBindingObserver {
  String? url;
  VideoManager? videoManager;
  bool isInitializing = true;
  BetterPlayerController? playerController;
  bool hasError = false;
  YoutubeExplode? _youtubeExplode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    url = widget.url;
    _youtubeExplode = YoutubeExplode();
    initializeVideo();
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      url = widget.url;
      _refreshVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    videoManager?.disposeAllVideo();
    _youtubeExplode?.close();
    _youtubeExplode = null;
    super.dispose();
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
        break;
      case AppLifecycleState.detached:
        playerController?.pause();
        break;
      default:
        break;
    }
  }

  Future<void> _refreshVideo() async {
    if (mounted) {
      setState(() {
        isInitializing = true;
        hasError = false;
      });
    }

    try {
      await videoManager?.refreshUrl(url: url);
      playerController = await videoManager?.controller;
      await ensureVideoInitialized();
    } catch (e) {
      debugPrint('Error refreshing video: $e');
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
    }

    if (mounted) {
      setState(() {
        isInitializing = false;
      });
    }
  }

  Future<void> initializeVideo() async {
    if (url == null || url!.isEmpty) {
      debugPrint('No video URL provided');
      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = true;
        });
      }
      return;
    }

    try {
      debugPrint('Initializing video with URL: $url');
      String? streamUrl = url;

      // Check if the URL is a YouTube URL
      final videoId = _extractYouTubeId(url!);
      if (videoId != null) {
        debugPrint('Detected YouTube URL, fetching stream manifest');
        final streamManifest = await _fetchStreamManifestWithRetry(videoId);
        final streamInfo = _selectBestStream(streamManifest);
        if (streamInfo == null) {
          throw Exception('No suitable muxed stream found for YouTube video');
        }
        streamUrl = streamInfo.url.toString();
        debugPrint('Selected YouTube stream: ${streamInfo.videoQualityLabel}');
      }

      videoManager = VideoManager(
        callbackEventListener: (eventType, videoLength) {
          if (widget.callbackEventListener != null) {
            widget.callbackEventListener!(eventType, videoLength);
          }
        },
        url: streamUrl,
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
        onPlay: () {
          debugPrint('Video started playing');
          widget.onPlay?.call();
        },
        callbackByPercentVideo: widget.callbackByPercentVideo,
        percentCallbackDefault: widget.percentCallbackDefault,
        onCompleted: () {
          debugPrint('Video completed');
          widget.onComplete();
        },
        videoTitle: widget.videoTitle,
        videoArtist: widget.videoArtist,
        videoThumbnail: widget.videoThumbnail,
      );

      widget.setVideoManager(videoManager!);

      await Future.any([
        Future.delayed(Duration(seconds: 10)),
        _getControllerWithRetry(),
      ]);

      await ensureVideoInitialized();
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    }
  }

  String? _extractYouTubeId(String url) {
    // Simple regex to extract YouTube video ID from various URL formats
    final RegExp regex = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      final videoId = match.group(2);
      if (videoId != null && videoId.length == 11) {
        return videoId;
      }
    }
    return null;
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

  MuxedStreamInfo? _selectBestStream(StreamManifest streamManifest) {
    final mp4Streams = streamManifest.muxed
        .where((info) => info.container == StreamContainer.mp4)
        .toList();

    if (mp4Streams.isNotEmpty) {
      mp4Streams.sort((a, b) {
        final preferredOrder = [
          'medium360',
          'medium480',
          'large720',
          'hd1080',
        ];
        final aQuality = a.videoQuality.name;
        final bQuality = b.videoQuality.name;
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

      debugPrint('Selected MP4 stream: ${mp4Streams.first.videoQualityLabel}');
      return mp4Streams.first;
    }

    final fallback = streamManifest.muxed.firstOrNull;
    debugPrint('No MP4 streams found, using fallback: ${fallback?.videoQualityLabel}');
    return fallback;
  }

  Future<void> _getControllerWithRetry() async {
    int attempts = 0;
    while (attempts < 30 && playerController == null) {
      try {
        playerController = await videoManager?.controller;
        if (playerController != null) {
          debugPrint('Controller obtained successfully');
          break;
        }
      } catch (e) {
        debugPrint('Error getting controller (attempt ${attempts + 1}): $e');
      }
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;
    }

    if (playerController == null) {
      throw Exception('Failed to get video controller after 30 attempts');
    }
  }

  Future<void> ensureVideoInitialized() async {
    if (playerController == null) {
      debugPrint('No player controller available');
      return;
    }

    try {
      int attempts = 0;
      bool isInitialized = false;

      while (attempts < 50 && !isInitialized) {
        if (playerController!.videoPlayerController?.value.initialized == true) {
          final duration = playerController!.videoPlayerController!.value.duration;
          if (duration != null && duration.inMilliseconds > 0) {
            debugPrint('Video successfully initialized with duration: ${duration.inSeconds}s');
            isInitialized = true;
            break;
          }
        }
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      if (!isInitialized) {
        debugPrint('Video not properly initialized, attempting reload');
        try {
          await playerController!.retryDataSource();
          await Future.delayed(Duration(milliseconds: 1000));
        } catch (e) {
          debugPrint('Error during retry: $e');
          throw e;
        }
      }
    } catch (e) {
      debugPrint('Error ensuring video initialization: $e');
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
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
              'Failed to load video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  isInitializing = true;
                });
                initializeVideo();
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
    if (hasError) {
      return _buildErrorWidget();
    }

    if (isInitializing || playerController == null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CircularProgressIndicator(),
      ));
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: playerController!),
    );
  }
}