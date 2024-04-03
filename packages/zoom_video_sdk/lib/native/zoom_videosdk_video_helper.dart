import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_camera_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
///@nodoc
abstract class ZoomVideoSdkVideoHelperPlatform extends PlatformInterface {
  ZoomVideoSdkVideoHelperPlatform() : super(token: _token);

  static final Object _token = Object();
  static ZoomVideoSdkVideoHelperPlatform _instance = ZoomVideoSdkVideoHelper();
  static ZoomVideoSdkVideoHelperPlatform get instance => _instance;
  static set instance(ZoomVideoSdkVideoHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> startVideo() async {
    throw UnimplementedError('startVideo() has not been implemented.');
  }

  Future<String> stopVideo() async {
    throw UnimplementedError('stopVideo() has not been implemented.');
  }

  Future<bool> switchCamera(String deviceId) async {
    throw UnimplementedError('switchCamera() has not been implemented.');
  }

  Future<bool> rotateMyVideo(num rotation) async {
    throw UnimplementedError('rotateMyVideo() has not been implemented.');
  }

  Future<List<ZoomVideoSdkCameraDevice>> getCameraList() async {
    throw UnimplementedError('getCameraList() has not been implemented.');
  }

  Future<num> getNumberOfCameras() async {
    throw UnimplementedError('getNumberOfCameras() has not been implemented.');
  }

  Future<bool> isMyVideoMirrored() async {
    throw UnimplementedError('isMyVideoMirrored() has not been implemented.');
  }

  Future<String> mirrorMyVideo(bool enable) async {
    throw UnimplementedError('mirrorMyVideo() has not been implemented.');
  }

  Future<bool> isOriginalAspectRatioEnabled() async {
    throw UnimplementedError('isOriginalAspectRatioEnabled() has not been implemented.');
  }

  Future<bool> enableOriginalAspectRatio(bool enable) async {
    throw UnimplementedError('enableOriginalAspectRatio() has not been implemented.');
  }

}

/// Zoom Video SDK Video Helper
class ZoomVideoSdkVideoHelper extends ZoomVideoSdkVideoHelperPlatform {
  final methodChannel = const MethodChannel('flutter_zoom_videosdk');

  /// Start sending local video data from the camera.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> startVideo() async {
    return await methodChannel
        .invokeMethod<String>('startVideo')
        .then<String>((String? value) => value ?? "");
  }

  /// Stop sending local video data from the camera.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> stopVideo() async {
    return await methodChannel
        .invokeMethod<String>('stopVideo')
        .then<String>((String? value) => value ?? "");
  }

  /// Switch to the next available camera.
  /// <br />Return true if the switch to the next camera was successful. Otherwise, this function returns false.
  @override
  Future<bool> switchCamera(String deviceId) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("deviceId", () => deviceId);

    return await methodChannel
        .invokeMethod<bool>('switchCamera', params)
        .then<bool>((bool? value) => value ?? false);
  }

  /// Rotate the video when the device is rotated.
  /// This happens during the device onConfigurationChanged or onResume within Activity.
  /// For more information regarding onConfigurationChanged, see https://developer.android.com/reference/android/app/Activity#onConfigurationChanged(android.content.res.Configuration).
  /// For more information regarding onResume, see https://developer.android.com/reference/android/app/Activity#onResume().
  /// <br />Return true if the rotation was successful. Otherwise, this function returns false.
  @override
  Future<bool> rotateMyVideo(num rotation) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("rotation", () => rotation);

    return await methodChannel
        .invokeMethod<bool>('rotateMyVideo', params)
        .then<bool>((bool? value) => value ?? false);
  }

  /// Get the list of camera devices available to share the video.
  /// <br />Return List of [ZoomVideoSDKCameraDevice] in string
  @override
  Future<List<ZoomVideoSdkCameraDevice>> getCameraList() async {
    var cameraListString = await methodChannel
        .invokeMethod<String>('getCameraList')
        .then<String>((String? value) => value ?? "");

    var cameraListJson = jsonDecode(cameraListString!) as List;
    List<ZoomVideoSdkCameraDevice> cameraList = cameraListJson
    .map((cameraJson) => ZoomVideoSdkCameraDevice.fromJson(cameraJson))
        .toList();

    return cameraList;
  }

  /// Get the number of cameras available to share the video.
  /// <br />Return number of cameras.
  @override
  Future<num> getNumberOfCameras() async {
    return await methodChannel
        .invokeMethod<num>('getNumberOfCameras')
        .then<num>((num? value) => value ?? 0);
  }

  /// Call this method to query mirror my video enable.
  /// <br />Return true if the mirror effect enabled, false otherwise.
  @override
  Future<bool> isMyVideoMirrored() async {
    return await methodChannel
        .invokeMethod<bool>('isMyVideoMirrored')
        .then<bool>((bool? value) => value ?? false);
  }

  /// Call this method to mirror my video.
  /// <br />[enable] true: mirror my video, false: disable the mirror effect
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> mirrorMyVideo(bool enable) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("enable", () => enable);
    return await methodChannel
        .invokeMethod<String>('mirrorMyVideo', params)
        .then<String>((String? value) => value ?? "");
  }

  /// Determine whether current aspect ratio is the original aspect ratio of video.the camera.
  /// <br />Return true if is original aspect ratio, otherwise false.
  @override
  Future<bool> isOriginalAspectRatioEnabled() async {
    return await methodChannel
        .invokeMethod<bool>('isOriginalAspectRatioEnabled')
        .then<bool>((bool? value) => value ?? false);
  }

  /// This function is used to set the aspect ratio of the video sent out.
  /// <br />[enable] true if you want to enable the original aspect ratio.
  /// <br />Return true if successful, otherwise false
  /// Remark: If session is using video source and data_mode is not VideoSourceDataMode_None, default always use original aspect ration of video.
  @override
  Future<bool> enableOriginalAspectRatio(bool enable) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("enable", () => enable);
    return await methodChannel
        .invokeMethod<bool>('enableOriginalAspectRatio', params)
        .then<bool>((bool? value) => value ?? false);
  }

}
