import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart' as fzv;
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';

// To show video or avatar of user
class VideoView extends fzv.ZoomView {
  final String? avatarUrl;
  const VideoView({
    super.key,
    required this.avatarUrl,
    required super.user,
    required super.fullScreen,
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

  double get _previewWidth => 110.0;
  double get _previewHeight => 146.0;
  double get _previewRoundedRadius => 10.0;
  double get _ratio => 4 / 3;

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
    // Fullscreen view
    if (fullScreen) {
      final Map<String, dynamic> creationParams = _buildCreationParams();
      Widget zoomView = fzv.View(
        key: Key('userId: ${user!.userId}, fullScreen: true, sharing: $sharing'),
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
              double width = mediaData.size.width;
              double height = width * _ratio;
              double ratio = mediaData.size.height / height;
              return Container(
                width: mediaData.size.width,
                height: mediaData.size.height,
                color: Colors.black,
                alignment: Alignment.center,
                child: ClipRect(
                  child: AspectRatio(
                    aspectRatio: 1.0 / _ratio,
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      heightFactor: ratio,
                      alignment: Alignment.center,
                      child: zoomView,
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
            child: _buildAvatarWidget(size: 64.0),
          );
        },
      );
    }

    return FutureBuilder(
      future: user!.videoStatus?.isOn(),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasData && snapshot.data == true) {
          final Map<String, dynamic> creationParams = _buildCreationParams();
          child = Container(
            child: fzv.View(
              key: Key('fullScreen: false, sharing: false'),
              creationParams: creationParams,
            ),
          );
        } else {
          child = Container(
            child: _buildAvatarWidget(),
          );
        }
        double _roundedRadius = _previewRoundedRadius;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_roundedRadius),
            color: Colors.black,
          ),
          width: _previewWidth,
          height: _previewHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_roundedRadius),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget({double? size}) {
    return Container(
      alignment: Alignment.center,
      child: avatarUrl?.isNotEmpty == true
          ? CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(avatarUrl!),
            )
          : Icon(
              Icons.person,
              size: size ?? 32.0,
              color: Colors.white,
            ),
    );
  }
}
