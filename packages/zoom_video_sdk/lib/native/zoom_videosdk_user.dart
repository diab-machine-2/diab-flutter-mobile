import 'dart:core';

import 'package:flutter/services.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_audio_status.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_share_statistic_info.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_video_statistic_info.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_video_status.dart';

/// Zoom Video SDK User
class ZoomVideoSdkUser {
  String userId; /// the identify of the user
  String customUserId; /// the custom identify of the user
  String userName; /// the name of the user
  bool? isHost; /// true: if the user is the host of the session
  bool? isManager; /// true: if the user is the manager of the session
  bool isSharing; /// true: if the user is sharing
  bool? hasMultiCamera; /// true: if the user has multiple cameras
  String? multiCameraIndex; /// the index of the multiple cameras
  ZoomVideoSdkAudioStatus? audioStatus; /// the audio status of the user
  ZoomVideoSdkVideoStatus? videoStatus; /// the video status of the user
  ZoomVideoSdkVideoStatisticInfo? videoStatisticInfo; /// the video statistic information of the user
  ZoomVideoSdkShareStatisticInfo? shareStatisticInfo; /// the share statistic information of the user

  final methodChannel = const MethodChannel('flutter_zoom_videosdk');

  ZoomVideoSdkUser(
      this.userId,
      this.customUserId,
      this.userName,
      this.isHost,
      this.isManager,
      this.hasMultiCamera,
      this.multiCameraIndex,
      this.isSharing);

  ZoomVideoSdkUser.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        customUserId = json['customUserId'],
        userName = json['userName'],
        isHost = json['isHost'],
        isManager = json['isManager'],
        isSharing = false,
        hasMultiCamera = json['hasMultiCamera'],
        multiCameraIndex = json['multiCameraIndex'],
        audioStatus = ZoomVideoSdkAudioStatus(json['userId']),
        videoStatus = ZoomVideoSdkVideoStatus(json['userId']),
        videoStatisticInfo = ZoomVideoSdkVideoStatisticInfo(json['userId']),
        shareStatisticInfo = ZoomVideoSdkShareStatisticInfo(json['userId']);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'customUserId': customUserId,
        'userName': userName,
        'isHost': isHost,
        'isManager': isManager,
        'hasMultiCamera': hasMultiCamera,
        'multiCameraIndex': multiCameraIndex
      };

  /// Get the name of the user in the session.
  /// <br />Return the name of the user in the session.
  Future<String> getUserName() async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);

    return await methodChannel
        .invokeMethod<String>('getUserName', params)
        .then<String>((String? value) => value ?? "");
  }

  /// Get the user's screen share status.
  /// <br />Return the share status of the user in the session.
  Future<String> getShareStatus() async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);

    return await methodChannel
        .invokeMethod<String>('getShareStatus', params)
        .then<String>((String? value) => value ?? "");
  }

  /// Determine whether the user is the host.
  /// <br />Return true indicates that the user is the host, otherwise false.
  Future<bool> getIsHost() async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);

    return await methodChannel
        .invokeMethod<bool>('isHost', params)
        .then<bool>((bool? value) => value ?? false);
  }

  /// Set the user's local volume. This does not affect how other participants hear the user.
  /// <br />[userId] the identify of the user
  /// <br />[volume] the volume of the user
  /// <br />[isShareAudio] true: if the user is sharing audio, otherwise false
  /// <br />Return true the methods succeeds, otherwise false.
  Future<bool> setUserVolume(String userId, num volume, bool isShareAudio) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);
    params.putIfAbsent("volume", () => volume);
    params.putIfAbsent("isShareAudio", () => isShareAudio);

    return await methodChannel
        .invokeMethod<bool>('setUserVolume', params)
        .then<bool>((bool? value) => value ?? false);
  }

  /// Get user volume.
  /// <br />[userId] the identify of the user
  /// <br />[isShareAudio] true: if the user is sharing audio, otherwise false
  /// <br />Return user volume.
  Future<num> getUserVolume(String userId, bool isShareAudio) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);
    params.putIfAbsent("isShareAudio", () => isShareAudio);

    return await methodChannel
        .invokeMethod<num>('getUserVolume', params)
        .then<num>((num? value) => value ?? -1);
  }

  /// Determine which audio you can set, shared audio or microphone.
  /// <br />[userId] the identify of the user
  /// <br />[isShareAudio] true: if the user is sharing audio, otherwise false
  /// <br />Return true if can set user volume, otherwise false
  Future<bool> canSetUserVolume(String userId, bool isShareAudio) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);
    params.putIfAbsent("isShareAudio", () => isShareAudio);

    return await methodChannel
        .invokeMethod<bool>('canSetUserVolume', params)
        .then<bool>((bool? value) => value ?? false);
  }
}
