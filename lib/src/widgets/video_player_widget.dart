import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerController? _controller;

  @override
  void initState() {
    if (widget.videoUrl.isNotEmpty) {
      _controller = BetterPlayerController(
        const BetterPlayerConfiguration(allowedScreenSleep: false, autoPlay: true),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.videoUrl,
        ),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose(forceDispose: true);
      _controller = null;
      print("Disposed controller from Framework.");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.textDark,
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: widget.videoUrl.isEmpty
                ? const SizedBox.shrink()
                : _controller != null
                    ? BetterPlayer(controller: _controller!)
                    : Container(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: IconButton(
              onPressed: () {
                NavigationUtil.pop(context);
              },
              icon: const Icon(
                Icons.close_rounded,
              ),
              color: R.color.white,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
