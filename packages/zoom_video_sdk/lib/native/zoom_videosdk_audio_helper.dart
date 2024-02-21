import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

///@nodoc
abstract class ZoomVideoSdkAudioHelperPlatform extends PlatformInterface {
  ZoomVideoSdkAudioHelperPlatform() : super(token: _token);

  static final Object _token = Object();
  static ZoomVideoSdkAudioHelperPlatform _instance = ZoomVideoSdkAudioHelper();
  static ZoomVideoSdkAudioHelperPlatform get instance => _instance;
  static set instance(ZoomVideoSdkAudioHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> canSwitchSpeaker() async {
    throw UnimplementedError('canSwitchSpeaker() has not been implemented.');
  }

  Future<bool> getSpeakerStatus() async {
    throw UnimplementedError('getSpeakerStatus() has not been implemented.');
  }

  Future<String> muteAudio(String userId) async {
    throw UnimplementedError('muteAudio() has not been implemented.');
  }

  Future<String> unMuteAudio(String userId) async {
    throw UnimplementedError('unMuteAudio() has not been implemented.');
  }

  Future<void> setSpeaker(bool isOn) async {
    throw UnimplementedError('setSpeaker() has not been implemented.');
  }

  Future<String> startAudio() async {
    throw UnimplementedError('startAudio() has not been implemented.');
  }

  Future<String> stopAudio() async {
    throw UnimplementedError('stopAudio() has not been implemented.');
  }

  Future<String> subscribe() async {
    throw UnimplementedError('subscribe() has not been implemented.');
  }

  Future<String> unSubscribe() async {
    throw UnimplementedError('unSubscribe() has not been implemented.');
  }

  Future<bool> resetAudioSession() async {
    throw UnimplementedError('resetAudioSession() has not been implemented.');
  }

  Future<void> cleanAudioSession() async {
    throw UnimplementedError('cleanAudioSession() has not been implemented.');
  }
}

/// Audio control interface
class ZoomVideoSdkAudioHelper extends ZoomVideoSdkAudioHelperPlatform {
  final methodChannel = const MethodChannel('flutter_zoom_videosdk');

  /// Query is audio speaker enable.
  /// <br />Return true: enable false: disable (some pad not support telephony,or some device not support)
  @override
  Future<bool> canSwitchSpeaker() async {
    return await methodChannel
        .invokeMethod<bool>('canSwitchSpeaker')
        .then<bool>((bool? value) => value ?? false);
  }

  /// Get audio speaker status
  /// <br />Return true: speaker false: headset or earSpeaker
  @override
  Future<bool> getSpeakerStatus() async {
    return await methodChannel
        .invokeMethod<bool>('getSpeakerStatus')
        .then<bool>((bool? value) => value ?? false);
  }

  /// mute user's voip audio by [userId]
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> muteAudio(String userId) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);

    return await methodChannel
        .invokeMethod<String>('muteAudio', params)
        .then<String>((String? value) => value ?? "");
  }

  /// unmute user's voip audio by [userId]
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> unMuteAudio(String userId) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("userId", () => userId);

    return await methodChannel
        .invokeMethod<String>('unMuteAudio', params)
        .then<String>((String? value) => value ?? "");
  }

  /// Set audio speaker
  /// <br />[isOn] = true if is speaker
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<void> setSpeaker(bool isOn) async {
    var params = <String, dynamic>{};
    params.putIfAbsent("isOn", () => isOn);

    await methodChannel.invokeMethod<void>('setSpeaker', params);
  }

  /// Start audio with voip
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> startAudio() async {
    return await methodChannel
        .invokeMethod<String>('startAudio')
        .then<String>((String? value) => value ?? "");
  }

  /// Stop voip
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> stopAudio() async {
    return await methodChannel
        .invokeMethod<String>('stopAudio')
        .then<String>((String? value) => value ?? "");
  }

  /// subscribe audio raw data.
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> subscribe() async {
    return await methodChannel
        .invokeMethod<String>('startAudio')
        .then<String>((String? value) => value ?? "");
  }

  /// unsubscribe audio raw data
  /// <br />Return [ZoomVideoSDKError_Success] if the function succeeds. Otherwise, this function returns an error.
  @override
  Future<String> unSubscribe() async {
    return await methodChannel
        .invokeMethod<String>('startAudio')
        .then<String>((String? value) => value ?? "");
  }

  @override
  Future<bool> resetAudioSession() async {
    return await methodChannel
        .invokeMethod<bool>('startAudio')
        .then<bool>((bool? value) => value ?? false);
  }

  @override
  Future<void> cleanAudioSession() async {
    await methodChannel.invokeMethod<void>('cleanAudioSession');
  }
}
