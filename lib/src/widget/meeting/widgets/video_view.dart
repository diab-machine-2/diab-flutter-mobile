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
    bool preview = false,
    bool focused = false,
    bool hasMultiCamera = false,
    String multiCameraIndex = "0",
    String videoAspect = VideoAspect.Original,
  }) : super(
          sharing: sharing,
          isPiPView: false,
          preview: preview,
          focused: focused,
          hasMultiCamera: hasMultiCamera,
          multiCameraIndex: multiCameraIndex,
          videoAspect: videoAspect,
        );

  double get _previewWidth => 110.0;
  double get _previewHeight => 146.0;
  double get _previewRoundedRadius => 10.0;

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
    // Fullscreen view
    if (fullScreen) {
      final size = MediaQuery.of(context).size;
      final Map<String, dynamic> creationParams = _buildCreationParams();
      Widget child = Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
        alignment: Alignment.center,
        child: fzv.View(
          key: Key('fullScreen: true, sharing: $sharing'),
          creationParams: creationParams,
        ),
      );
      if (sharing) {
        return InteractiveViewer(
          child: child,
          minScale: 1.0,
          maxScale: 2.5,
        );
      }
      return FutureBuilder(
        future: user!.videoStatus?.isOn(),
        builder: (context, snapshot) {
          print("Fullscreen => VideoView: ${snapshot.data}");
          if (snapshot.hasData && snapshot.data == true) {
            return child;
          }
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 0),
            color: Colors.black,
            child: _buildAvatarWidget(),
          );
        },
      );
    }

    return FutureBuilder(
      future: user!.videoStatus?.isOn(),
      builder: (context, snapshot) {
        print("Preview => VideoView: ${snapshot.data}");
        Widget child;
        if (snapshot.hasData && snapshot.data == true) {
          final Map<String, dynamic> creationParams = _buildCreationParams();
          child = Container(
            child: fzv.View(
              key: Key('fullScreen: false'),
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

  Widget _buildAvatarWidget() {
    return Container(
      alignment: Alignment.center,
      child: avatarUrl?.isNotEmpty == true
          ? CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(avatarUrl!),
            )
          : Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
    );
  }
}
