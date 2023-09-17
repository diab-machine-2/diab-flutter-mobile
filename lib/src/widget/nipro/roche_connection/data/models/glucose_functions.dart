import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/nipro/roche_connection/data/models/GlucoseMeasurementRecord.dart';
import 'dart:typed_data';

int FORMAT_UINT8 = 17;
int FORMAT_UINT16 = 18;
int gregorianCalendar = 1792;
// UUID của các đặc tính
const String uuidGlucoseMeasurement = '00002a18-0000-1000-8000-00805f9b34fb';
const String RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID =
    '00002a52-0000-1000-8000-00805f9b34fb';
const String GLUCOSE_MEASUREMENT_CONTEXT_CHARACTERISTIC_UUID =
    "00002A34-0000-1000-8000-00805f9b34fb";

// Thời gian bắt đầu (30 ngày trước)
DateTime baseTime = DateTime.now().subtract(const Duration(days: 90));
int timeOffset = baseTime.difference(DateTime(1970)).inSeconds;

class GlucoseFunctions {
// Hàm đọc dữ liệu lịch sử từ characteristic Glucose Measurement
  Future<List<int>> readHistoryData(
      BluetoothCharacteristic characteristic) async {
    print(characteristic.properties.write);
    if (characteristic.properties.read) {
      // Cấu hình CCCD để cho phép đọc
      await characteristic.setNotifyValue(true);

      // Đọc dữ liệu từ characteristic
      List<int> response = await characteristic.read();

      return response;
    } else {
      print("Characteristic không hỗ trợ đọc");
    }
    return [];
  }

// Hàm thực hiện các bước cấu hình và lấy dữ liệu lịch sử
  Future<void> fetchDataFromAccuChek(List<BluetoothService> services) async {
    // Lấy danh sách các services và characteristics
    // List<BluetoothService> services = await device!.discoverServices();

    // Tìm characteristic Glucose Measurement
    BluetoothCharacteristic? glucoseMeasurementCharacteristic;
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == uuidGlucoseMeasurement) {
          glucoseMeasurementCharacteristic = characteristic;
          break;
        }
      }
    }

    // Tìm characteristic RACP
    BluetoothCharacteristic? racpCharacteristic;
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
          racpCharacteristic = characteristic;
          break;
        }
      }
    }
  }

  Future<void> writeData2A52(BluetoothCharacteristic racpCharacteristic) async {
    // Cấu hình CCCD cho Glucose Measurement và RACP
    if (racpCharacteristic.uuid ==
        Guid('00002a52-0000-1000-8000-00805f9b34fb')) {
      // Đăng ký sự kiện lắng nghe dữ liệu từ characteristic
      racpCharacteristic.setNotifyValue(true);

// Lắng nghe sự kiện thay đổi dữ liệu từ characteristic
      racpCharacteristic.value.listen((data) {
        print('PHUONG data: $data');
      });
      try {
        print('PHUONG characteristic.uuid: ${racpCharacteristic.uuid}');
        List<int> requestData = [0x01, 0x01]; // Op Code: 0x01
        // List<int> requestData = [0x05, 0x04]; // Op Code: 0x01
        // List<int> requestData = [0x01, 0x00]; // Op Code: 0x01
        // List<int> requestData = [0x04, 0x06]; // Op Code: 0x01
        await Future.delayed(const Duration(milliseconds: 400));
        await racpCharacteristic.write(requestData);
        // List<int> historyData = await readHistoryData(racpCharacteristic);
        // print('PHUONG Lịch sử đo đường huyết: $historyData');
      } catch (e) {
        print('PHUONG $e');
      }
    }
    // await configureCCCD(
    //     racpvalues, [0x01, 0x06]); // Enable notifications
    // // await configureCCCD(racpvalues, [0x02, 0x00]); // Enable indications

    // // Gửi yêu cầu RACP với thời gian bắt đầu
    // await sendRACPCommand(racpvalues,
    //     [0x01, timeOffset & 0xFF, (timeOffset >> 8) & 0xFF]);

    // Đọc dữ liệu lịch sử từ Glucose Measurement

    // Ngắt kết nối với thiết bị
    // device?.disconnect();
  }

  Future<void> writeDataSubmit(List<BluetoothService> services) async {
    BluetoothCharacteristic? racpCharacteristic;

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
          racpCharacteristic = characteristic;
          break;
        }
      }
    }
  }

  int getIntValue(List<int> values, int type, int offset) {
    // Đọc giá trị từ thuộc tính Bluetooth
    // List<int>? values = await characteristic.read();
    int unit8 = values[offset];

    if (type == FORMAT_UINT16) {
      Uint16List uint16List =
          Uint16List.fromList([unit8]); // Chuyển đổi sang Uint16List
      return uint16List[0]; // Lấy giá trị Uint16 đầu tiên
    } else {
      return unit8;
    }
  }

  double getFloatValue(List<int> values, int offset) {
    // Đọc giá trị từ thuộc tính Bluetooth
    // List<int>? values = await characteristic.read();
    int unit8 = values[offset];
    return unit8 / 100000;
  }

  GlucoseMeasurementRecord readDataFrom2A18(List<int> values) {
    var glucoseMeasurementRecord = GlucoseMeasurementRecord();
    int offset = 0;
    int flag = getIntValue(values, FORMAT_UINT8, offset);
    // Console.log("PHUONG $offset flag", flag);

    offset++; // offset is 1

    glucoseMeasurementRecord.sequenceNumber =
        getIntValue(values, FORMAT_UINT16, 1);

    // Console.log("PHUONG $offset sequenceNumber",
    // glucoseMeasurementRecord.sequenceNumber);

    offset += 2; // offset is 3
    int baseTimeYear = gregorianCalendar + values[offset];

    // Console.log("PHUONG $offset baseTimeYear", baseTimeYear);
    offset += 2; // offset is 5
    int baseTimeMonth = getIntValue(values, FORMAT_UINT8, offset++);
    // Console.log("PHUONG $offset baseTimeMonth", baseTimeMonth);
    int baseTimeDay = getIntValue(values, FORMAT_UINT8, offset++);
    // Console.log("PHUONG $offset baseTimeDay", baseTimeDay);
    int baseTimeHours = getIntValue(values, FORMAT_UINT8, offset++);
    // Console.log("PHUONG $offset baseTimeHours", baseTimeHours);
    int baseTimeMinutes = getIntValue(values, FORMAT_UINT8, offset++);
    // Console.log("PHUONG $offset baseTimeMinutes", baseTimeMinutes);
    int baseTimeSeconds = getIntValue(values, FORMAT_UINT8, offset++);
    // Console.log("PHUONG $offset baseTimeSeconds", baseTimeSeconds);

    glucoseMeasurementRecord.calendar = DateTime(
      baseTimeYear,
      baseTimeMonth,
      baseTimeDay,
      baseTimeHours,
      baseTimeMinutes,
      baseTimeSeconds,
    );

    int timeOffset = 0;
    if ((flag & (1 << 0)) > 0) {
      timeOffset = (values[11] * 256) + values[10];
      offset += 2; // offset is 12
    }
    glucoseMeasurementRecord.timeOffset = timeOffset;

    glucoseMeasurementRecord.calendar =
        glucoseMeasurementRecord.calendar!.add(Duration(minutes: timeOffset));

    // Console.log("PHUONG flag & (1 << 1)) > 0", (flag & (1 << 1)) > 0);
    late double glucoseConcentrationValue;
    if ((flag & (1 << 1)) > 0) {
      // int typeAndSampleLocation =
      //     getIntValue(values, FORMAT_UINT8, offset);
      // offset += 1; // offset is 15
      // Console.log("PHUONG $offset location", typeAndSampleLocation);

      // Console.log("PHUONG (flag & (1 << 2)) > 0", (flag & (1 << 2)) > 0);
      glucoseMeasurementRecord.glucoseUnits = calculateGlucoseUnit(values);
      glucoseConcentrationValue = extractSFloat(values, offset);

      // Console.log('PHUONG glucoseUnit',
      //     glucoseMeasurementRecord.glucoseConcentrationMeasurementUnit);
      offset += 2; // offset is 14
      int typeAndSampleLocation = values[offset];
      // Console.log('PHUONG location $offset', typeAndSampleLocation);
      glucoseMeasurementRecord.type = typeAndSampleLocation >> 4;
      glucoseMeasurementRecord.sampleLocationInteger =
          typeAndSampleLocation & 0x0F;
      glucoseMeasurementRecord.glucoseConcentrationValue =
          glucoseConcentrationValue;
      // Console.log('PHUONG type $offset', glucoseMeasurementRecord.type);
      // Console.log('PHUONG LocationInteger $offset',
      //     glucoseMeasurementRecord.sampleLocationInteger);
    }
    // Console.log("PHUONG (flag & (1 << 2)) > 0", (flag & (1 << 2)) > 0);
    // if ((flag & (1 << 2)) > 0) {
    //   // Sensor Status Annunciation field is present
    int sensorStatusAnnunciationValue =
        getIntValue(values, FORMAT_UINT16, offset);
    offset += 2; // offset is 16 or 12 or 9

    //   SensorStatusAnnunciation sensorStatusAnnunciation =
    //       SensorStatusAnnunciation();
    //   sensorStatusAnnunciation.deviceBatteryLowAtTimeOfMeasurement =
    //       sensorStatusAnnunciationValue & (1 << 0) > 0;
    //   sensorStatusAnnunciation.sensorMalfunctionAtTimeOfMeasurement =
    //       sensorStatusAnnunciationValue & (1 << 1) > 0;
    //   sensorStatusAnnunciation.bloodSampleInsufficientAtTimeOfMeasurement =
    //       sensorStatusAnnunciationValue & (1 << 2) > 0;
    //   sensorStatusAnnunciation.stripInsertionError =
    //       sensorStatusAnnunciationValue & (1 << 3) > 0;
    //   sensorStatusAnnunciation.stripTypeIncorrectForDevice =
    //       sensorStatusAnnunciationValue & (1 << 4) > 0;
    //   sensorStatusAnnunciation.sensorResultHigherThanDeviceCanProcess =
    //       sensorStatusAnnunciationValue & (1 << 5) > 0;
    //   sensorStatusAnnunciation.sensorResultLowerThanTheDeviceCanProcess =
    //       sensorStatusAnnunciationValue & (1 << 6) > 0;
    //   sensorStatusAnnunciation.
    bool sensorTemperatureTooHighForValidTestResult =
        sensorStatusAnnunciationValue & (1 << 7) > 0;
    // bool sensorTemperatureTooLowForValidTestResult =
    //     sensorStatusAnnunciationValue & (1 << 8) > 0;
    //   sensorStatusAnnunciation
    //           .sensorReadInterruptedBecauseStripWasPulledTooSoon =
    //       sensorStatusAnnunciationValue & (1 << 9) > 0;
    //   sensorStatusAnnunciation.generalDeviceFaultHasOccurredInSensor =
    //       sensorStatusAnnunciationValue & (1 << 10) > 0;
    //   sensorStatusAnnunciation.timeFaultHasOccurredInTheSensor =
    //       sensorStatusAnnunciationValue & (1 << 11) > 0;

    //   glucoseMeasurementRecord.sensorStatusAnnunciation =
    //       sensorStatusAnnunciation;
    // } else {}
    // glucoseMeasurementRecord.isControlGlucose = isControlGlucose(values[1]);

    glucoseMeasurementRecord.isBloodGlucose = values[14] == 248 &&
        !glucoseMeasurementRecord.glucoseConcentrationValue.isInfinite;
    // if (!isControlGlucose(values[1])) {
    // print(
    //     'sensorTemperatureTooHighForValidTestResult ${glucoseMeasurementRecord.calendar} heigt -> $sensorTemperatureTooHighForValidTestResult, low -> $sensorTemperatureTooLowForValidTestResult: ${glucoseMeasurementRecord.convertGlucoseConcentrationValueToMilligramsPerDeciliter()}}');
    // print(
    //     'isControlGlucose $values: ${glucoseMeasurementRecord.convertGlucoseConcentrationValueToMilligramsPerDeciliter()} -> ${isControlGlucose(values[1])}');
    // }
    // print('isBloodGlucose sensorTemperatureeodGlucose: ${glucoseMeasurementRecord.isBloodGlucose} --> ${glucoseMeasurementRecord.convertGlucoseConcentrationValueToMilligramsPerDeciliter()}');
    // if () {
    //   print(
    //       'isBloodGlucose => ${values[14]} $values =-> ${glucoseMeasurementRecord.glucoseConcentrationValue}');
    //   Console.log('values[13]: ${values[13]}',
    //       glucoseMeasurementRecord.glucoseConcentrationValue);
    // }
    // if (glucoseMeasurementRecord.isBloodGlucose) {
    Console.log(
        'hihi $values =>  ${glucoseMeasurementRecord.glucoseUnits}',
        glucoseMeasurementRecord
            .convertGlucoseConcentrationValueToMilligramsPerDeciliter());
    // }
    return glucoseMeasurementRecord;
    // Broadcast the glucose measurement record
    // LocalBroadcastManager.getInstance().sendBroadcast(
    //   Intent(BluetoothGattStateInformationReceiver
    //       .BLUETOOTH_LE_GATT_ACTION_GLUCOSE_MEASUREMENT_RECORD_AVAILABLE)
    //     ..putExtra(
    //       BluetoothGattStateInformationReceiver
    //           .BLUETOOTH_LE_GATT_GLUCOSE_MEASUREMENT_RECORD_EXTRA,
    //       glucoseMeasurementRecord,
    //     ),
    // );
    // else if (characteristic.uuid ==
    //     GlucoseProfileConfiguration
    //         .GLUCOSE_MEASUREMENT_CONTEXT_CHARACTERISTIC_UUID) {
    //   // Todo, handle the value of the glucose measurement context characteristic
    // } else if (characteristic.uuid ==
    //     GlucoseProfileConfiguration
    //         .RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
    //   print('RECORDS_SENT_COMPLETE');
    //   // LocalBroadcastManager.getInstance().sendBroadcast(
    //   //   Intent(BluetoothGattStateInformationReceiver.RECORDS_SENT_COMPLETE),
    //   // );
    // } else {
    //   // Handle other characteristics if needed
    // }
  }

  double floatToSFloat(int value) {
    int intValue = (value * 16).round();
    int sFloatValue = intValue & 0xFFFF;
    return sFloatValue.toDouble();
  }

// Hàm để chuyển đổi dữ liệu từ FORMAT_SFLOAT (float16) sang số thực trong Flutter
  double extractSFloat(List<int> values, int startingIndex) {
    // Đảm bảo mảng dữ liệu không bị tràn hoặc vượt quá chỉ số
    if (startingIndex + 1 >= values.length) {
      throw Exception("Invalid index or data array size.");
    }

    // Lấy hai byte đầu tiên để biểu diễn số nguyên 16-bit
    int full = values[startingIndex + 1] * 256 + values[startingIndex];

    // Tiến hành chuyển đổi tương tự như trong mã Swift
    if (full == 0x07FF) {
      return double.nan;
    } else if (full == 0x0800) {
      return double.nan;
    } else if (full == 0x07FE) {
      return double.infinity;
    } else if (full == 0x0802) {
      return -double.infinity;
    } else if (full == 0x0801) {
      return double.nan;
    }

    int expo = (full & 0xF000) >> 12;
    double expoFloat = floatFromTwosComplementUInt16(expo, 4);

    int mantissa = full & 0x0FFF;
    double mantissaFloat = floatFromTwosComplementUInt16(mantissa, 12);

    double finalValue = mantissaFloat * pow(10.0, expoFloat);

    return finalValue;
  }

// Hàm để chuyển đổi số thực từ số nguyên có dấu 16-bit (FORMAT_SFLOAT) sang số thực Dart
  double floatFromTwosComplementUInt16(int value, int bits) {
    // Đảo bit ký hiệu nếu có
    if ((value & (1 << (bits - 1))) != 0) {
      value = -((1 << bits) - value);
    }

    return value.toDouble();
  }

  bool isBitSet(int value, int n) {
    print('isBitSet: ${value & (1 << n)}');
    return (value & (1 << n)) != 0;
  }

  GlucoseUnitsFlag calculateGlucoseUnit(List<int> data) {
    // Trường "Flags" nằm ở byte đầu tiên
    int flags = data[0];
    String bit2 = flags.toRadixString(2);

    // Kiểm tra bit thứ 2 của trường "Flags" để xác định đơn vị Glucose Concentration
    if (isBitSet(flags, 2)) {
      return GlucoseUnitsFlag.mmolPerL;
    } else {
      return GlucoseUnitsFlag.mgPerDL;
    }

    // int flags = data[0];

    // // Kiểm tra bit thứ 1 của trường "Flags" để xem có xuất hiện các trường "Glucose Concentration" và "Type-Sample Location" trong dữ liệu hay không
    // if (isBitSet(flags, 0)) {
    //   // Nếu bit thứ 1 là 1, thì xác định giá trị của trường "Type-Sample Location" (ở đây là byte thứ 8)
    //   int typeSampleLocation = data[8];

    //   // Kiểm tra bit thứ 0 của trường "Type-Sample Location" để xác định đơn vị Glucose Concentration
    //   if (isBitSet(typeSampleLocation, 2)) {
    //     print('hihi GlucoseUnitsFlag.mmolPerL $data');
    //     return GlucoseUnitsFlag.mmolPerL;
    //   } else {
    //     print('hihi GlucoseUnitsFlag.mgPerDL $data');
    //     return GlucoseUnitsFlag.mgPerDL;
    //   }
    // }
    // return GlucoseUnitsFlag.mmolPerL;
  }
}
