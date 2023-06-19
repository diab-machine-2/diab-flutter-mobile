import 'package:medical/src/widget/helper/helper.dart';

import 'sensor_status_annunciation.dart';

class GlucoseMeasurementRecord {
  int sequenceNumber;
  DateTime? calendar;
  num timeOffset;
  GlucoseConcentrationMeasurementUnit glucoseConcentrationMeasurementUnit;
  double glucoseConcentrationValue;
  int type;
  int sampleLocationInteger;
  String testBloodType;
  String sampleLocation;
  SensorStatusAnnunciation? sensorStatusAnnunciation;

  GlucoseMeasurementRecord({
    this.sequenceNumber = 0,
    this.calendar,
    this.timeOffset = 0,
    this.glucoseConcentrationMeasurementUnit =
        GlucoseConcentrationMeasurementUnit.molesPerLitre,
    this.glucoseConcentrationValue = 0.0,
    this.type = 0,
    this.sampleLocationInteger = 0,
    this.testBloodType = 'Capillary Whole blood',
    this.sampleLocation = 'Earlobe',
    this.sensorStatusAnnunciation,
  });

  String convertGlucoseConcentrationValueToMilligramsPerDeciliter() {
    return '${roundDouble(glucoseConcentrationValue * 100000)}';
  }
}

enum GlucoseConcentrationMeasurementUnit {
  molesPerLitre,
  kilogramsPerLitre,
}

extension GlucoseMeasurementRecordExtensions on GlucoseMeasurementRecord {
  void initialize() {
    testBloodType = _getTestBloodType();
    sampleLocation = _getSampleLocation();
  }

  String _getTestBloodType() {
    switch (type) {
      case 0:
        return 'Reserved for future use';
      case 1:
        return 'Capillary Whole blood';
      case 2:
        return 'Capillary Plasma';
      case 3:
        return 'Venous Whole blood';
      case 4:
        return 'Venous Plasma';
      case 5:
        return 'Arterial Whole blood';
      case 6:
        return 'Arterial Plasma';
      case 7:
        return 'Undetermined Whole blood';
      case 8:
        return 'Undetermined Plasma';
      case 9:
        return 'Interstitial Fluid (ISF)';
      case 10:
        return 'Control Solution';
      default:
        return 'Reserved for future use';
    }
  }

  String _getSampleLocation() {
    switch (sampleLocationInteger) {
      case 0:
        return 'Reserved for future use';
      case 1:
        return 'Finger';
      case 2:
        return 'Alternate Site Test (AST)';
      case 3:
        return 'Earlobe';
      case 4:
        return 'Control solution';
      case 15:
        return 'Sample Location value not available';
      default:
        return 'Reserved for future use';
    }
  }
}
