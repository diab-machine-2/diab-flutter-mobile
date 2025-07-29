import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoWidget extends StatefulWidget {
  final String videoUrl;
  final Function({YoutubeMetaData? meta}) onEnded;
  final Function({YoutubeMetaData? meta}) onPlay;
  const YoutubeVideoWidget(
      {Key? key,
      required this.videoUrl,
      required this.onEnded,
      required this.onPlay})
      : super(key: key);

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget>
    with WidgetsBindingObserver {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isPlayerStarted = false;

  late YoutubeMetaData _videoMetaData;

  @override
  void initState() {
    super.initState();

    var id = YoutubePlayer.convertUrlToId(widget.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: id!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        hideThumbnail: false,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Don't auto-pause when app goes to background or device is locked
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Keep audio playing
        debugPrint('YouTube: App paused/inactive - keeping audio playing');
        break;
      case AppLifecycleState.resumed:
        debugPrint('YouTube: App resumed');
        break;
      case AppLifecycleState.detached:
        _controller.pause();
        break;
      default:
        break;
    }
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }

    // When player is started for the first time and still playing
    if (_isPlayerStarted == false && _controller.value.isPlaying) {
      setState(() {
        if (_videoMetaData.videoId.isNotEmpty) {
          widget.onPlay(meta: _videoMetaData);
          _isPlayerStarted = true;
        }
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () => _isPlayerReady = true,
        onEnded: (data) => widget.onEnded(meta: data),
      ),
      builder: (context, player) => player,
    );
  }
}
