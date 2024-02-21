import 'dart:core';

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
