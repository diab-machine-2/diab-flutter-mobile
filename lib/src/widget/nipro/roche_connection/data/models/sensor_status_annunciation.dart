class SensorStatusAnnunciation {
  bool deviceBatteryLowAtTimeOfMeasurement;
  bool sensorMalfunctionAtTimeOfMeasurement;
  bool bloodSampleInsufficientAtTimeOfMeasurement;
  bool stripInsertionError;
  bool stripTypeIncorrectForDevice;
  bool sensorResultHigherThanDeviceCanProcess;
  bool sensorResultLowerThanTheDeviceCanProcess;
  bool sensorTemperatureTooHighForValidTestResult;
  bool sensorTemperatureTooLowForValidTestResult;
  bool sensorReadInterruptedBecauseStripWasPulledTooSoon;
  bool generalDeviceFaultHasOccurredInSensor;
  bool timeFaultHasOccurredInTheSensor;

  SensorStatusAnnunciation({
    this.deviceBatteryLowAtTimeOfMeasurement = false,
    this.sensorMalfunctionAtTimeOfMeasurement = false,
    this.bloodSampleInsufficientAtTimeOfMeasurement = false,
    this.stripInsertionError = false,
    this.stripTypeIncorrectForDevice = false,
    this.sensorResultHigherThanDeviceCanProcess = false,
    this.sensorResultLowerThanTheDeviceCanProcess = false,
    this.sensorTemperatureTooHighForValidTestResult = false,
    this.sensorTemperatureTooLowForValidTestResult = false,
    this.sensorReadInterruptedBecauseStripWasPulledTooSoon = false,
    this.generalDeviceFaultHasOccurredInSensor = false,
    this.timeFaultHasOccurredInTheSensor = false,
  });

  factory SensorStatusAnnunciation.fromJson(Map<String, dynamic> json) {
    return SensorStatusAnnunciation(
      deviceBatteryLowAtTimeOfMeasurement:
          json['deviceBatteryLowAtTimeOfMeasurement'] ?? false,
      sensorMalfunctionAtTimeOfMeasurement:
          json['sensorMalfunctionAtTimeOfMeasurement'] ?? false,
      bloodSampleInsufficientAtTimeOfMeasurement:
          json['bloodSampleInsufficientAtTimeOfMeasurement'] ?? false,
      stripInsertionError: json['stripInsertionError'] ?? false,
      stripTypeIncorrectForDevice: json['stripTypeIncorrectForDevice'] ?? false,
      sensorResultHigherThanDeviceCanProcess:
          json['sensorResultHigherThanDeviceCanProcess'] ?? false,
      sensorResultLowerThanTheDeviceCanProcess:
          json['sensorResultLowerThanTheDeviceCanProcess'] ?? false,
      sensorTemperatureTooHighForValidTestResult:
          json['sensorTemperatureTooHighForValidTestResult'] ?? false,
      sensorTemperatureTooLowForValidTestResult:
          json['sensorTemperatureTooLowForValidTestResult'] ?? false,
      sensorReadInterruptedBecauseStripWasPulledTooSoon:
          json['sensorReadInterruptedBecauseStripWasPulledTooSoon'] ?? false,
      generalDeviceFaultHasOccurredInSensor:
          json['generalDeviceFaultHasOccurredInSensor'] ?? false,
      timeFaultHasOccurredInTheSensor:
          json['timeFaultHasOccurredInTheSensor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceBatteryLowAtTimeOfMeasurement':
          deviceBatteryLowAtTimeOfMeasurement,
      'sensorMalfunctionAtTimeOfMeasurement':
          sensorMalfunctionAtTimeOfMeasurement,
      'bloodSampleInsufficientAtTimeOfMeasurement':
          bloodSampleInsufficientAtTimeOfMeasurement,
      'stripInsertionError': stripInsertionError,
      'stripTypeIncorrectForDevice': stripTypeIncorrectForDevice,
      'sensorResultHigherThanDeviceCanProcess':
          sensorResultHigherThanDeviceCanProcess,
      'sensorResultLowerThanTheDeviceCanProcess':
          sensorResultLowerThanTheDeviceCanProcess,
      'sensorTemperatureTooHighForValidTestResult':
          sensorTemperatureTooHighForValidTestResult,
      'sensorTemperatureTooLowForValidTestResult':
          sensorTemperatureTooLowForValidTestResult,
      'sensorReadInterruptedBecauseStripWasPulledTooSoon':
          sensorReadInterruptedBecauseStripWasPulledTooSoon,
      'generalDeviceFaultHasOccurredInSensor':
          generalDeviceFaultHasOccurredInSensor,
      'timeFaultHasOccurredInTheSensor': timeFaultHasOccurredInTheSensor,
    };
  }
}
