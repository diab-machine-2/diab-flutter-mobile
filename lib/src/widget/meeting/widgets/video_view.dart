import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart' as fzv;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';

// To show video or avatar of user
class VideoView extends fzv.ZoomView {
  final String? avatarUrl;
  const VideoView({
    super.key,
    required this.avatarUrl,
    required super.user,
    bool sharing = false,
    bool preview = false,
    bool focused = false,
    bool hasMultiCamera = false,
    String multiCameraIndex = "0",
    String videoAspect = VideoAspect.Original,
    required super.fullScreen,
    required super.resolution,
  }) : super(
          sharing: sharing,
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
    final isVideoOn = useState(false);
    final isMuted = useState(false);
    final isMounted = useIsMounted();
    final zoom = ZoomVideoSdk();
    user?.audioStatus?.isMuted().then((muted) => isMuted.value = muted);

    useEffect(() {
      updateVideoStatus() {
        if (user == null) return;
        Future<void>.microtask(() async {
          if (isMounted()) {
            isVideoOn.value = (await user!.videoStatus!.isOn());
          }
        });
      }

      updateVideoStatus();
      return null;
    }, [zoom, user]);

    // Fullscreen view
    if (fullScreen) {
      if (sharing || isVideoOn.value) {
        final Map<String, dynamic> creationParams = _buildCreationParams();
        var size = MediaQuery.of(context).size;
        return Container(
          width: size.width,
          height: size.height,
          alignment: Alignment.center,
          child: fzv.View(
            creationParams: creationParams,
          ),
        );
      }
      // Just show avatar
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        color: Colors.black,
        child: _buildAvatarWidget(),
      );
    }

    // Preview
    Widget backgroundW;
    if (isVideoOn.value) {
      final Map<String, dynamic> creationParams = _buildCreationParams();
      backgroundW = Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        child: fzv.View(
          creationParams: creationParams,
        ),
      );
    } else {
      backgroundW = Container(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: _buildAvatarWidget(),
      );
    }
    // Expect aspect ration 16:9, rounded
    double _roundedRadius = _previewRoundedRadius;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_roundedRadius),
        color: Colors.black,
      ),
      width: _previewWidth,
      height: _previewHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_roundedRadius),
        child: backgroundW,
      ),
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
