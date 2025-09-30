import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/exercise_tab/exercise_detail/models/video_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';

class ExerciseVideoWidget extends StatefulWidget {
  ExerciseVideoWidget({
    required this.url,
    required this.onComplete,
    this.onPlay,
    this.callbackByPercentVideo,
    this.percentCallbackDefault = 1,
    this.callbackEventListener,
    required this.videoManager,
    this.videoTitle,
    this.videoArtist,
    this.videoThumbnail,
    this.exerciseData,
  });

  final String url;
  final VoidCallback onComplete;
  final VoidCallback? onPlay;
  final VoidCallback? callbackByPercentVideo;
  final Function(CustomPlayerEventType, Duration)? callbackEventListener;
  final double percentCallbackDefault;
  final VideoManager videoManager;
  final String? videoTitle;
  final String? videoArtist;
  final String? videoThumbnail;
  final ExerciseMovementResponseData? exerciseData;

  @override
  _ExerciseVideoWidgetState createState() => _ExerciseVideoWidgetState();
}

class _ExerciseVideoWidgetState extends State<ExerciseVideoWidget>
    with WidgetsBindingObserver {
  VideoManager? videoManager;
  bool isInitializing = true;
  BetterPlayerController? playerController;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeVideo();
  }

  @override
  void didUpdateWidget(ExerciseVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _refreshVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle like lesson detail page
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is paused or device locked - keep audio playing
        debugPrint(
            '[EXERCISE] App paused/inactive - keeping video audio playing');
        break;
      case AppLifecycleState.resumed:
        // App resumed
        debugPrint('[EXERCISE] App resumed');
        break;
      case AppLifecycleState.detached:
        // App is about to be terminated - pause the video
        if (videoManager
                ?.controller?.videoPlayerController?.value.initialized ==
            true) {
          videoManager?.controller?.pause();
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

  Future<void> initializeVideo() async {
    if (widget.url.isEmpty) {
      debugPrint('[EXERCISE] No video URL provided');
      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = true;
        });
      }
      return;
    }

    try {
      debugPrint('[EXERCISE] Using provided videoManager');
      playerController = widget.videoManager.controller;

      // Ensure video is properly initialized
      await widget.videoManager.waitForVideoReady();

      debugPrint('[EXERCISE] Video manager initialized successfully');
    } catch (e) {
      debugPrint('[EXERCISE] Error initializing video: $e');
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

  Future<void> _refreshVideo() async {
    if (mounted) {
      setState(() {
        isInitializing = true;
        hasError = false;
      });
    }

    try {
      // Reinitialize video using the provided videoManager
      await widget.videoManager.waitForVideoReady();
    } catch (e) {
      debugPrint('[EXERCISE] Error refreshing video: $e');
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

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(R.color.greenGradientBottom),
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
      return _buildLoadingWidget();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: playerController!),
    );
  }
}
