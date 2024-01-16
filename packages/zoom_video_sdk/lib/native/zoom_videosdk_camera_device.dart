import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Zoom Video SDK camera device.
class ZoomVideoSdkCameraDevice {

  String deviceId; /// camera device id
  String deviceName; /// camera device name
  bool? isSelectedDevice; /// true:if the device is selected

  ZoomVideoSdkCameraDevice(this.deviceId, this.deviceName, this.isSelectedDevice);

  ZoomVideoSdkCameraDevice.fromJson(Map<String, dynamic> json) :
    deviceId = json['deviceId'],
    deviceName = json['deviceName'],
    isSelectedDevice = json['isSelectedDevice'];

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'isSelectedDevice': isSelectedDevice,
  };
}
