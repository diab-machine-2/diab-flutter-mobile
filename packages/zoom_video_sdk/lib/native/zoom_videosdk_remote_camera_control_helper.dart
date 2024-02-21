import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
///@nodoc
abstract class ZoomVideoSdkRemoteCameraControlHelperPlatform extends PlatformInterface {
  ZoomVideoSdkRemoteCameraControlHelperPlatform() : super(token: _token);

  static final Object _token = Object();
  static ZoomVideoSdkRemoteCameraControlHelperPlatform _instance =
  ZoomVideoSdkRemoteCameraControlHelper();
  static ZoomVideoSdkRemoteCameraControlHelperPlatform get instance => _instance;
  static set instance(ZoomVideoSdkRemoteCameraControlHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> giveUpControlRemoteCamera() async {
    throw UnimplementedError('giveUpControlRemoteCamera() has not been implemented.');
  }

  Future<String> requestControlRemoteCamera() async {
    throw UnimplementedError('requestControlRemoteCamera() has not been implemented.');
  }

  Future<String> turnLeft() async {
    throw UnimplementedError('turnLeft() has not been implemented.');
  }

  Future<String> turnRight() async {
    throw UnimplementedError('turnRight() has not been implemented.');
  }

  Future<String> turnDown() async {
    throw UnimplementedError('turnDown() has not been implemented.');
  }

  Future<String> turnUp() async {
    throw UnimplementedError('turnUp() has not been implemented.');
  }

  Future<String> zoomIn() async {
    throw UnimplementedError('zoomIn() has not been implemented.');
  }

  Future<String> zoomOut() async {
    throw UnimplementedError('zoomOut() has not been implemented.');
  }

}

/// Interface to control far-end camera (Only for Android)
class ZoomVideoSdkRemoteCameraControlHelper extends ZoomVideoSdkRemoteCameraControlHelperPlatform {
  final methodChannel = const MethodChannel('flutter_zoom_videosdk');

  /// Give up control of the remote camera.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> giveUpControlRemoteCamera() async {
    return await methodChannel
        .invokeMethod<String>('giveUpControlRemoteCamera')
        .then<String>((String? value) => value ?? "");
  }

  /// Request to control remote camera.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> requestControlRemoteCamera() async {
    return await methodChannel
        .invokeMethod<String>('requestControlRemoteCamera')
        .then<String>((String? value) => value ?? "");
  }

  /// Turn the camera to the left by [range].
  /// Rotation range,  10 <= range <= 100.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> turnLeft() async {
    return await methodChannel
        .invokeMethod<String>('turnLeft')
        .then<String>((String? value) => value ?? "");
  }

  /// Turn the camera to the right by [range].
  /// Rotation range,  10 <= range <= 100.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> turnRight() async {
    return await methodChannel
        .invokeMethod<String>('turnRight')
        .then<String>((String? value) => value ?? "");
  }

  /// Turn the camera down by [range].
  /// Rotation range,  10 <= range <= 100.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> turnDown() async {
    return await methodChannel
        .invokeMethod<String>('turnDown')
        .then<String>((String? value) => value ?? "");
  }

  /// Turn the camera up by [range].
  /// Rotation range,  10 <= range <= 100.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> turnUp() async {
    return await methodChannel
        .invokeMethod<String>('turnUp')
        .then<String>((String? value) => value ?? "");
  }

  /// Zoom in the camera by [range].
  /// Zoom range,  10 <= range <= 100.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> zoomIn() async {
    return await methodChannel
        .invokeMethod<String>('zoomIn')
        .then<String>((String? value) => value ?? "");
  }

  /// Zoom out the camera by [range].
  /// Zoom range,  10 <= range <= 100.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds.
  @override
  Future<String> zoomOut() async {
    return await methodChannel
        .invokeMethod<String>('zoomOut')
        .then<String>((String? value) => value ?? "");
  }

}
