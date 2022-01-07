import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
    super.initState();
  }

  Future<BetterPlayerController?> getController() async {
    var path;
    try {
      path = (await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 190,
        quality: 10,
      ));
    } catch (e) {
      path = null;
    }

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        allowedScreenSleep: false,
        autoPlay: true,
        showPlaceholderUntilPlay: true,
        placeholder: path != null ? Image.file(File(path!)) : Container(),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
      ),
    );
    return _controller;
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.dispose(forceDispose: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.textDark,
      body: Stack(
        children: [
          FutureBuilder(
              future: getController(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var controller = snapshot.data! as BetterPlayerController;
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: widget.videoUrl.isEmpty ? const SizedBox.shrink() : BetterPlayer(controller: controller),
                );
              }),
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
