import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    url = widget.url;
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Don't auto-pause when app goes to background or device is locked
    // This allows audio to continue playing in background
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is paused or device locked - keep audio playing
        debugPrint('App paused/inactive - keeping video audio playing');
        // Don't pause the video here to allow background audio playback
        break;
      case AppLifecycleState.resumed:
        // App resumed
        debugPrint('App resumed');
        break;
      case AppLifecycleState.detached:
        // App is about to be terminated - pause the video
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

      videoManager = VideoManager(
        callbackEventListener: (eventType, videoLength) {
          if (widget.callbackEventListener != null) {
            widget.callbackEventListener!(eventType, videoLength);
          }
        },
        url: url,
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

      // Get the controller reference with timeout
      await Future.any([
        Future.delayed(Duration(seconds: 10)), // 10 second timeout
        _getControllerWithRetry(),
      ]);

      // Ensure video is properly initialized
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
      // Wait for up to 5 seconds for the video to initialize properly
      int attempts = 0;
      bool isInitialized = false;

      while (attempts < 50 && !isInitialized) {
        if (playerController!.videoPlayerController?.value.initialized ==
            true) {
          final duration =
              playerController!.videoPlayerController!.value.duration;
          if (duration != null && duration.inMilliseconds > 0) {
            debugPrint(
                'Video successfully initialized with duration: ${duration.inSeconds}s');
            isInitialized = true;
            break;
          }
        }
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      // If still not initialized properly, attempt to reload
      if (!isInitialized) {
        debugPrint('Video not properly initialized, attempting reload');
        try {
          await playerController!.retryDataSource();
          // Wait a bit more after retry
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
