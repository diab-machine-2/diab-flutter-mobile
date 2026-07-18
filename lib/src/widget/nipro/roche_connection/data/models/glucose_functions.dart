import 'dart:developer' as developer;
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

  /// Helper: tên loại máu từ type integer (BLE spec)
  String _testBloodTypeName(int type) {
    switch (type) {
      case 0: return 'Reserved for future use';
      case 1: return 'Capillary Whole blood';
      case 2: return 'Capillary Plasma';
      case 3: return 'Venous Whole blood';
      case 4: return 'Venous Plasma';
      case 5: return 'Arterial Whole blood';
      case 6: return 'Arterial Plasma';
      case 7: return 'Undetermined Whole blood';
      case 8: return 'Undetermined Plasma';
      case 9: return 'Interstitial Fluid (ISF)';
      case 10: return 'Control Solution';
      default: return 'Reserved for future use';
    }
  }

  /// Helper: tên vị trí lấy mẫu từ sampleLocationInteger (BLE spec)
  String _sampleLocationName(int location) {
    switch (location) {
      case 0: return 'Reserved for future use';
      case 1: return 'Finger';
      case 2: return 'Alternate Site Test (AST)';
      case 3: return 'Earlobe';
      case 4: return 'Control solution';
      case 15: return 'Sample Location value not available';
      default: return 'Reserved for future use';
    }
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

    // ============================================================
    // 🛠️ DEV LOG: RAW BLE DATA (Glucose Measurement 0x2A18)
    // ============================================================
    developer.log('╔══════════════════════════════════════════════╗',
        name: 'diaB.BLE');
    developer.log('║  📦 RAW DATA (${values.length} bytes)             ║',
        name: 'diaB.BLE');
    developer.log(
        '║  Hex: ${values.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
        name: 'diaB.BLE');
    developer.log('╚══════════════════════════════════════════════╝',
        name: 'diaB.BLE');

    // --- Flags ---
    developer.log('── FLAGS ───────────────────────────────',
        name: 'diaB.BLE');
    developer.log('  Byte 0 (flags)     = ${flag.toRadixString(2).padLeft(8, '0')}b = 0x${flag.toRadixString(16).padLeft(2, '0')} = $flag',
        name: 'diaB.BLE');
    developer.log('    Bit 0 (Time Offset present):  ${flag & (1 << 0) > 0}',
        name: 'diaB.BLE');
    developer.log('    Bit 1 (Glucose conc + Type  ):  ${flag & (1 << 1) > 0}',
        name: 'diaB.BLE');
    developer.log('    Bit 2 (Glucose unit):          ${flag & (1 << 2) > 0}  (0=mg/dL, 1=mmol/L)',
        name: 'diaB.BLE');
    developer.log('    Bit 3 (Status Annunc present): ${flag & (1 << 3) > 0}',
        name: 'diaB.BLE');
    developer.log('    Bit 4-7 (reserved):            ${(flag >> 4).toRadixString(4).padLeft(4, '0')}b',
        name: 'diaB.BLE');

    offset++; // offset is 1

    // --- Sequence Number ---
    glucoseMeasurementRecord.sequenceNumber =
        getIntValue(values, FORMAT_UINT16, 1);
    developer.log('── BASIC INFO ──────────────────────────',
        name: 'diaB.BLE');
    developer.log('  Sequence Number    = ${glucoseMeasurementRecord.sequenceNumber}',
        name: 'diaB.BLE');

    offset += 2; // offset is 3
    int baseTimeYear = gregorianCalendar + values[offset];
    developer.log('  Raw year byte     = ${values[offset]} (gregorianCalendar + ${values[offset]} = $baseTimeYear)',
        name: 'diaB.BLE');

    offset += 2; // offset is 5
    int baseTimeMonth = getIntValue(values, FORMAT_UINT8, offset++);
    int baseTimeDay = getIntValue(values, FORMAT_UINT8, offset++);
    int baseTimeHours = getIntValue(values, FORMAT_UINT8, offset++);
    int baseTimeMinutes = getIntValue(values, FORMAT_UINT8, offset++);
    int baseTimeSeconds = getIntValue(values, FORMAT_UINT8, offset++);
    developer.log('  Timestamp (meter) = $baseTimeYear-$baseTimeMonth-$baseTimeDay ${baseTimeHours.toString().padLeft(2,'0')}:${baseTimeMinutes.toString().padLeft(2,'0')}:${baseTimeSeconds.toString().padLeft(2,'0')}',
        name: 'diaB.BLE');

    // Convert standard local time into standard absolute epoch.
    // The previous workaround (DateTime.utc) is no longer needed since
    // helper.dart's convertToUTC has been fixed globally to parse as local time.
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
      // Time Offset is a 16-bit signed integer (minutes), little-endian per BLE spec
      final lo = values[10];
      final hi = values[11];
      int signed = (hi << 8) | lo;
      if (signed >= 0x8000) signed -= 0x10000; // two's complement to int16
      timeOffset = signed;
      offset += 2; // offset is 12
    }
    glucoseMeasurementRecord.timeOffset = timeOffset;

    glucoseMeasurementRecord.calendar =
        glucoseMeasurementRecord.calendar!.add(Duration(minutes: timeOffset));

    developer.log('── TIME ────────────────────────────────',
        name: 'diaB.BLE');
    developer.log('  Time Offset        = $timeOffset minutes',
        name: 'diaB.BLE');
    developer.log('  Time after offset  = ${glucoseMeasurementRecord.calendar}',
        name: 'diaB.BLE');
    developer.log('  Epoch seconds      = ${glucoseMeasurementRecord.calendar!.millisecondsSinceEpoch ~/ 1000}',
        name: 'diaB.BLE');
    developer.log('  Device timezone    = ${glucoseMeasurementRecord.calendar!.timeZoneName} (offset: ${glucoseMeasurementRecord.calendar!.timeZoneOffset.inHours}h)',
        name: 'diaB.BLE');

    late double glucoseConcentrationValue;
    if ((flag & (1 << 1)) > 0) {
      glucoseMeasurementRecord.glucoseUnits = calculateGlucoseUnit(values);
      glucoseConcentrationValue = extractSFloat(values, offset);

      developer.log('── GLUCOSE VALUE ────────────────────────',
          name: 'diaB.BLE');
      developer.log('  Glucose unit       = ${glucoseMeasurementRecord.glucoseUnits} (0=mg/dL, 1=mmol/L)',
          name: 'diaB.BLE');
      developer.log('  Raw SFloat bytes   = values[$offset]=${values[offset]}, values[${offset+1}]=${values[offset+1]}',
          name: 'diaB.BLE');
      developer.log('  Glucose (raw)      = $glucoseConcentrationValue',
          name: 'diaB.BLE');

      offset += 2; // offset is 14
      int typeAndSampleLocation = values[offset];
      glucoseMeasurementRecord.type = typeAndSampleLocation >> 4;
      glucoseMeasurementRecord.sampleLocationInteger =
          typeAndSampleLocation & 0x0F;
      glucoseMeasurementRecord.glucoseConcentrationValue =
          glucoseConcentrationValue;

      developer.log('  Type+Sample byte   = ${typeAndSampleLocation.toRadixString(2).padLeft(8, '0')}b = 0x${typeAndSampleLocation.toRadixString(16).padLeft(2, '0')}',
          name: 'diaB.BLE');
      developer.log('    Type (4 bit cao) = ${glucoseMeasurementRecord.type} → ${glucoseMeasurementRecord.testBloodType.isNotEmpty ? glucoseMeasurementRecord.testBloodType : _testBloodTypeName(glucoseMeasurementRecord.type)}',
          name: 'diaB.BLE');
      developer.log('    SampleLoc (4 thấp)= ${glucoseMeasurementRecord.sampleLocationInteger} → ${glucoseMeasurementRecord.sampleLocation.isNotEmpty ? glucoseMeasurementRecord.sampleLocation : _sampleLocationName(glucoseMeasurementRecord.sampleLocationInteger)}',
          name: 'diaB.BLE');
    } else {
      developer.log('  ⚠️ Bit 1 = 0 → Không có glucose concentration + type/sample location trong packet này',
          name: 'diaB.BLE');
    }
    developer.log('── SENSOR STATUS ────────────────────────',
        name: 'diaB.BLE');
    int sensorStatusAnnunciationValue =
        getIntValue(values, FORMAT_UINT16, offset);
    offset += 2;
    developer.log('  Sensor Status Annunc = ${sensorStatusAnnunciationValue.toRadixString(2).padLeft(16, '0')}b',
        name: 'diaB.BLE');
    developer.log('    Device Battery Low        : ${sensorStatusAnnunciationValue & (1 << 0) > 0}',
        name: 'diaB.BLE');
    developer.log('    Sensor Malfunction        : ${sensorStatusAnnunciationValue & (1 << 1) > 0}',
        name: 'diaB.BLE');
    developer.log('    Insufficient Sample       : ${sensorStatusAnnunciationValue & (1 << 2) > 0}',
        name: 'diaB.BLE');
    developer.log('    Strip Insertion Error     : ${sensorStatusAnnunciationValue & (1 << 3) > 0}',
        name: 'diaB.BLE');
    developer.log('    Strip Type Incorrect      : ${sensorStatusAnnunciationValue & (1 << 4) > 0}',
        name: 'diaB.BLE');
    developer.log('    Result Too High           : ${sensorStatusAnnunciationValue & (1 << 5) > 0}',
        name: 'diaB.BLE');
    developer.log('    Result Too Low            : ${sensorStatusAnnunciationValue & (1 << 6) > 0}',
        name: 'diaB.BLE');
    developer.log('    Temperature Too High      : ${sensorStatusAnnunciationValue & (1 << 7) > 0}',
        name: 'diaB.BLE');
    developer.log('    Temperature Too Low       : ${sensorStatusAnnunciationValue & (1 << 8) > 0}',
        name: 'diaB.BLE');
    developer.log('    Strip Pulled Too Soon     : ${sensorStatusAnnunciationValue & (1 << 9) > 0}',
        name: 'diaB.BLE');
    developer.log('    Device Fault              : ${sensorStatusAnnunciationValue & (1 << 10) > 0}',
        name: 'diaB.BLE');
    developer.log('    Time Fault                : ${sensorStatusAnnunciationValue & (1 << 11) > 0}',
        name: 'diaB.BLE');

    glucoseMeasurementRecord.isBloodGlucose = values[14] == 248 &&
        !glucoseMeasurementRecord.glucoseConcentrationValue.isInfinite;

    developer.log('── CLASSIFICATION ────────────────────────',
        name: 'diaB.BLE');
    developer.log('  values[14]         = ${values[14]}',
        name: 'diaB.BLE');
    developer.log('  isBloodGlucose     = ${glucoseMeasurementRecord.isBloodGlucose}',
        name: 'diaB.BLE');
    developer.log('  glucoseConcentrationValue = ${glucoseMeasurementRecord.glucoseConcentrationValue}',
        name: 'diaB.BLE');
    developer.log(
        '  Glucose (mg/dL)    = ${glucoseMeasurementRecord.convertGlucoseConcentrationValueToMilligramsPerDeciliter()}',
        name: 'diaB.BLE');
    developer.log('══════════════════════════════════════════',
        name: 'diaB.BLE');

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
