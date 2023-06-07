import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// UUID của các đặc tính
const String uuidGlucoseMeasurement = '00002a18-0000-1000-8000-00805f9b34fb';
const String uuidRACP = '00002a52-0000-1000-8000-00805f9b34fb';

// Thời gian bắt đầu (30 ngày trước)
DateTime baseTime = DateTime.now().subtract(const Duration(days: 90));
int timeOffset = baseTime.difference(DateTime(1970)).inSeconds;

class GlucoseFunctions {
  // Hàm thực hiện cấu hình CCCD
  Future<void> configureCCCD(
      BluetoothCharacteristic characteristic, List<int> value) async {
    await characteristic.setNotifyValue(true);
    await characteristic.write(value);
  }

  // Hàm thực hiện yêu cầu gửi lệnh RACP
  Future<void> sendRACPCommand(
      BluetoothCharacteristic characteristic, List<int> value) async {
    await characteristic.write(value);
  }

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
        if (characteristic.uuid.toString() == uuidRACP) {
          racpCharacteristic = characteristic;
          break;
        }
      }
    }

    // Cấu hình CCCD cho Glucose Measurement và RACP
    await configureCCCD(glucoseMeasurementCharacteristic!,
        [0x01, 0x00]); // Enable notifications
    await configureCCCD(
        racpCharacteristic!, [0x02, 0x00]); // Enable indications

    // Gửi yêu cầu RACP với thời gian bắt đầu
    await sendRACPCommand(racpCharacteristic,
        [0x01, timeOffset & 0xFF, (timeOffset >> 8) & 0xFF]);

    // Đọc dữ liệu lịch sử từ Glucose Measurement
    List<int> historyData =
        await readHistoryData(glucoseMeasurementCharacteristic);

    print('Lịch sử đo đường huyết: $historyData');

    // Ngắt kết nối với thiết bị
    // device?.disconnect();
  }

  Future<void> writeData2A52(BluetoothCharacteristic racpCharacteristic) async {
    // Cấu hình CCCD cho Glucose Measurement và RACP
    await configureCCCD(
        racpCharacteristic, [0x01, 0x00]); // Enable notifications
    await configureCCCD(racpCharacteristic, [0x02, 0x00]); // Enable indications

    // Gửi yêu cầu RACP với thời gian bắt đầu
    await sendRACPCommand(racpCharacteristic,
        [0x01, timeOffset & 0xFF, (timeOffset >> 8) & 0xFF]);

    // Đọc dữ liệu lịch sử từ Glucose Measurement
    List<int> historyData = await readHistoryData(racpCharacteristic);

    print('Lịch sử đo đường huyết: $historyData');
  }
  
}
