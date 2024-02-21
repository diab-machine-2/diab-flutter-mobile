import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoWidget extends StatefulWidget {
  final String videoUrl;
  final Function onEnded;
  final Function onPlay;
  const YoutubeVideoWidget(
      {Key? key,
      required this.videoUrl,
      required this.onEnded,
      required this.onPlay})
      : super(key: key);

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isPlayerStarted = false;

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
      ),
    );
  }

  void listener() {
    if (_isPlayerStarted == false && _controller.value.isPlaying) {
      widget.onPlay();
      setState(() {
        _isPlayerStarted = true;
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
        onEnded: (data) => widget.onEnded(),
      ),
      builder: (context, player) => player,
    );
  }
}
