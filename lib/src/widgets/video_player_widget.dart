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
    initController();
    super.initState();
  }

  Future initController() async {
    // var path;
    // try {
    //   path = (await VideoThumbnail.thumbnailFile(
    //     video: widget.videoUrl,
    //     thumbnailPath: (await getTemporaryDirectory()).path,
    //     imageFormat: ImageFormat.PNG,
    //     maxHeight: 190,
    //     quality: 10,
    //   ));
    // } catch (e) {
    //   path = null;
    // }

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
     //   showPlaceholderUntilPlay: true,
         handleLifecycle: true,
      //  placeholder: path != null ? Image.file(File(path!),) : Container(),
      ),
    );
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.videoUrl,
        );
      _controller!.setupDataSource(betterPlayerDataSource);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose(forceDispose: true);
      _controller = null;
      print("Disposed controller");
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
                  child: widget.videoUrl.isEmpty ? const SizedBox.shrink() : BetterPlayer(controller: 
                  _controller!),
                ),
          // FutureBuilder(
          //     future: initController(),
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasData) {
          //         return Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //       var controller = snapshot.data! as BetterPlayerController;
          //       return Container(
          //         alignment: Alignment.center,
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //         ),
          //         child: widget.videoUrl.isEmpty ? const SizedBox.shrink() : BetterPlayer(controller: controller),
          //       );
          //     }),
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
