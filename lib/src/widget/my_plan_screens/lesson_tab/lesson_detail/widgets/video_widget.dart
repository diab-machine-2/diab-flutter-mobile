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
  });

  final String url;
  VoidCallback onComplete;
  VoidCallback? onPlay;
  VoidCallback? callbackByPercentVideo;
  final Function(CustomPlayerEventType, Duration)? callbackEventListener;
  double percentCallbackDefault;
  Function(VideoManager) setVideoManager;

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  String? url;
  VideoManager? videoManager;
  bool isInitializing = true;
  BetterPlayerController? playerController;

  @override
  void initState() {
    url = widget.url;
    initializeVideo();
    super.initState();
  }

  Future<void> initializeVideo() async {
    if (url != null) {
      videoManager = VideoManager(
          callbackEventListener: (eventType, videoLength) {
            if (widget.callbackEventListener != null) {
              widget.callbackEventListener!(eventType, videoLength);
            }
          },
          url: url,
          placeHolder: Image.asset(
            R.drawable.ic_thumbnail1,
            fit: BoxFit.fill,
          ),
          onExitFullScreen: () {},
          onPlay: widget.onPlay,
          callbackByPercentVideo: widget.callbackByPercentVideo,
          percentCallbackDefault: widget.percentCallbackDefault,
          onCompleted: () {
            widget.onComplete();
          });

      widget.setVideoManager(videoManager!);

      // Get the controller reference
      playerController = await videoManager?.controller;

      // Ensure video is properly initialized
      await ensureVideoInitialized();

      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    }
  }

  Future<void> ensureVideoInitialized() async {
    if (playerController != null) {
      // Wait for up to 3 seconds for the video to initialize properly
      int attempts = 0;
      while (attempts < 30) {
        if (playerController!.videoPlayerController?.value.duration != null &&
            playerController!
                    .videoPlayerController!.value.duration!.inMilliseconds >
                0) {
          debugPrint(
              'Video successfully initialized with duration: ${playerController!.videoPlayerController!.value.duration!.inSeconds}s');
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      // If still not initialized properly, attempt to reload
      if (playerController!.videoPlayerController?.value.duration == null ||
          playerController!
                  .videoPlayerController!.value.duration!.inMilliseconds <=
              0) {
        debugPrint('Video not properly initialized, attempting reload');
        await playerController!.retryDataSource();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing || playerController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return BetterPlayer(controller: playerController!);
  }
}
