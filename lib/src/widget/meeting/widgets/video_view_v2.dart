import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart' as fzv;
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/res/R.dart';

// To show video or avatar of user
class VideoViewV2 extends fzv.ZoomView {
  final String? avatarUrl;
  final bool isPiPMode;
  const VideoViewV2({
    super.key,
    required this.avatarUrl,
    required super.user,
    required super.fullScreen,
    this.isPiPMode = false,
    required super.resolution,
    bool sharing = false,
    bool isPiPView = false,
    bool preview = false,
    bool focused = false,
    bool hasMultiCamera = false,
    String multiCameraIndex = "0",
    String videoAspect = VideoAspect.PanAndScan,
  }) : super(
          sharing: sharing,
          isPiPView: isPiPView,
          preview: preview,
          focused: focused,
          hasMultiCamera: hasMultiCamera,
          multiCameraIndex: multiCameraIndex,
          videoAspect: videoAspect,
        );

  final double _ratio = 4 / 3;

  Map<String, dynamic> _buildCreationParams() {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    creationParams.putIfAbsent("userId", () => user?.userId);
    creationParams.putIfAbsent("sharing", () => sharing);
    creationParams.putIfAbsent("preview", () => preview);
    creationParams.putIfAbsent("focused", () => focused);
    creationParams.putIfAbsent("hasMultiCamera", () => hasMultiCamera);
    creationParams.putIfAbsent("isPiPView", () => isPiPView);
    if (videoAspect.isEmpty) {
      creationParams.putIfAbsent("videoAspect", () => VideoAspect.PanAndScan);
    } else {
      creationParams.putIfAbsent("videoAspect", () => videoAspect);
    }
    creationParams.putIfAbsent("fullScreen", () => fullScreen);
    if (resolution.isNotEmpty) {
      creationParams.putIfAbsent("videoAspect", () => videoAspect);
    }
    return creationParams;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SizedBox();
    }
    final media = MediaQuery.of(context);
    bool isLandScape = media.orientation == Orientation.landscape;
    final key = Key('userId: ${user!.userId}, sharing: $sharing');
    if (isPiPMode) {
      final Future<bool> futureSharing = Future.value(sharing);
      final Future<bool> futureVideoOn = user!.videoStatus?.isOn() ?? Future.value(false);
      return FutureBuilder(
        future: Future.wait([futureSharing, futureVideoOn]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool sharing = snapshot.data![0];
            final bool videoOn = snapshot.data![1];
            if (!sharing && !videoOn) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 0),
                color: Colors.black,
                child: _buildAvatarWidget(),
              );
            }
            final Map<String, dynamic> creationParams = _buildCreationParams();
            return fzv.View(
              key: key,
              creationParams: creationParams,
            );
          }
          return SizedBox();
        },
      );
    }

    final Map<String, dynamic> creationParams = _buildCreationParams();
    Widget zoomView = fzv.View(
      key: key,
      creationParams: creationParams,
    );
    if (sharing) {
      return InteractiveViewer(
        child: Container(
          width: media.size.width,
          height: media.size.height,
          color: Colors.black,
          alignment: Alignment.center,
          child: zoomView,
        ),
        minScale: 1.0,
        maxScale: 2.5,
        constrained: false,
      );
    }
    return FutureBuilder(
      future: user!.videoStatus?.isOn(),
      builder: (context, snapshot) {
        final mediaData = MediaQuery.of(context);
        if (snapshot.hasData && snapshot.data == true) {
          if (!isLandScape) {
            return Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: ClipRect(
                child: AspectRatio(
                  aspectRatio: 1.0 / _ratio,
                  child: OverflowBox(
                    maxHeight: mediaData.size.height,
                    child: SizedBox.expand(
                      child: zoomView,
                    ),
                  ),
                ),
              ),
            );
          }
          return Container(
            width: media.size.width,
            height: media.size.height,
            color: Colors.black,
            alignment: Alignment.center,
            child: zoomView,
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          color: Colors.black,
          child: _buildAvatarWidget(),
        );
      },
    );
  }

  Widget _buildAvatarWidget() {
    double size = 48.0;
    double paddingSize = 6.0;
    final avatarWidget = Container(
      clipBehavior: Clip.antiAlias,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: R.color.mainColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Icon(Icons.person, size: size - paddingSize * 2.0, color: R.color.white),
      ),
    );
    return Container(
      alignment: Alignment.center,
      child: avatarWidget,
    );
  }
}
