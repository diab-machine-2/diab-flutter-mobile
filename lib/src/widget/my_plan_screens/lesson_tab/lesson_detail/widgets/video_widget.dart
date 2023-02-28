import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  final Function(CustomPlayerEventType)? callbackEventListener;
  double percentCallbackDefault;
  Function(VideoManager) setVideoManager;

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  String? url;
//  var path;
  VideoManager? videoManager;

  @override
  void initState() {
    url = widget.url;
    getThumbnail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: videoManager!.controller!);
  }

  Future<void> getThumbnail() async {
    if (url != null) {
      // path = (await VideoThumbnail.thumbnailFile(
      //   video: url!,
      //   thumbnailPath: (await getTemporaryDirectory()).path,
      //   imageFormat: ImageFormat.PNG,
      //   maxHeight: 190,
      //   quality: 10,

      // ));
      // print('pathVideo = $path');

      videoManager = VideoManager(
          callbackEventListener: (event) {
            if (widget.callbackEventListener != null) {
              widget.callbackEventListener!(event);
            }
          },
          url: url,
          //    placeHolder: path != null ? Image.file(File(path!)) : Container(),
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
            // sectionStatus?.isVideoCompleted = true;
            // checkSectionComplete();
          });
      widget.setVideoManager(videoManager!);

      //     setState(() {});
    }
  }
}
