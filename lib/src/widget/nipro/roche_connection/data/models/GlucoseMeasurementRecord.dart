import 'package:medical/src/widget/helper/helper.dart';

import 'sensor_status_annunciation.dart';

enum GlucoseUnitsFlag {
  mgPerDL,
  mmolPerL,
}

class GlucoseMeasurementRecord {
  int sequenceNumber;
  DateTime? calendar;
  num timeOffset;
  GlucoseUnitsFlag glucoseUnits;
  double glucoseConcentrationValue;
  int type;
  int sampleLocationInteger;
  String testBloodType;
  String sampleLocation;
  bool isBloodGlucose;
  SensorStatusAnnunciation? sensorStatusAnnunciation;
  int? mealContextInteger;
  String? mealContextString;

  GlucoseMeasurementRecord({
    this.sequenceNumber = 0,
    this.calendar,
    this.timeOffset = 0,
    this.glucoseUnits = GlucoseUnitsFlag.mmolPerL,
    this.glucoseConcentrationValue = 0.0,
    this.type = 0,
    this.sampleLocationInteger = 0,
    this.testBloodType = 'Capillary Whole blood',
    this.sampleLocation = 'Earlobe',
    this.sensorStatusAnnunciation,
    this.isBloodGlucose = false,
    this.mealContextInteger,
    this.mealContextString,
  });

  String convertGlucoseConcentrationValueToMilligramsPerDeciliter() {
    return '${roundDouble(glucoseConcentrationValue * 100000)}';
  }
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

  String mealContextName() {
    switch (mealContextInteger) {
      case 1: return 'Preprandial (Trước bữa ăn)';
      case 2: return 'Postprandial (Sau bữa ăn)';
      case 3: return 'Fasting (Nhịn ăn)';
      case 4: return 'Casual (Ăn vặt/Uống)';
      case 5: return 'Bedtime (Trước khi ngủ)';
      default: return 'Unknown';
    }
  }

  /// Maps the BLE meal-context value to the server's TimeFrame `code`
  /// (see `/app/TimeFrame/Glucose`). `Casual` and `Bedtime` have no
  /// corresponding server timeframe and resolve to null.
  String? timeFrameCode() {
    switch (mealContextInteger) {
      case 1: return 'Prd17'; // Preprandial - Trước ăn
      case 2: return 'Prd18'; // Postprandial - Sau ăn
      case 3: return 'Prd16'; // Fasting - Đường huyết đói
      default: return null;
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
