import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  StreamController<bool> _placeholderStreamController =
      StreamController.broadcast();

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
        handleLifecycle: true,
        showPlaceholderUntilPlay: true,
        expandToFill: false,
        fit: BoxFit.fitHeight,
        placeholder: _buildVideoPlaceholder(),
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      ),
    );
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );
    _controller!.setupDataSource(betterPlayerDataSource);
    _controller!.addEventsListener((event) async {
          print('event.betterPlayerEventType = ${event.betterPlayerEventType}');
          if (event.betterPlayerEventType == BetterPlayerEventType.play){
            _placeholderStreamController.add(true);
          }
        },);
  }

  Widget _buildVideoPlaceholder() {
    return StreamBuilder<bool>(
      stream: _placeholderStreamController.stream,
      builder: (context, snapshot) {
        return snapshot.data ?? false
            ? Container(color: R.color.black)
            : Image.asset(R.drawable.ic_thumbnail1, fit: BoxFit.fill,);
      },
    );
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose(forceDispose: true);
      _controller = null;
      print("Disposed controller");
    }
    _placeholderStreamController.close();
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
            child: widget.videoUrl.isEmpty ? const SizedBox.shrink() : BetterPlayer(controller: _controller!),
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
