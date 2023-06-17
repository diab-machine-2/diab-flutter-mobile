import 'dart:math';

import 'package:medical/src/utils/app_log.dart';

class BlueUtils {
  static String getServiceTitle(serviceUuid) {
    String title = 'Service';
    if (serviceUuid.contains('180A')) {
      title += ' (Thông tin Thiết bị)';
    }
    if (serviceUuid.contains('1808')) {
      title += ' (Đường huyết)';
    }
    return title;
  }

  static String getCharacteristic(characteristicUuid, characteristic, value) {
    Console.log(
        '$characteristicUuid - (0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)})',
        value);
    String title = 'Characteristic';

    switch (characteristicUuid) {
      case '00002a18-0000-1000-8000-00805f9b34fb':
        title +=
            ' (được sử dụng để lưu trữ thông tin về đo lường nồng độ đường huyết. Nó chứa các thông số như nồng độ đường huyết, thời gian đo, kiểu đo, v.v)';
        break;
      case '00002a51-0000-1000-8000-00805f9b34fb':
        title +=
            ' (được sử dụng để cung cấp thông tin bổ sung liên quan đến đo lường nồng độ đường huyết, bao gồm thông tin về nguồn gốc mẫu, thời gian lấy mẫu, loại mẫu, v.v. Nó cung cấp bối cảnh cho dữ liệu được ghi lại trong Characteristic "Glucose Measurement" (UUID 00002a18-0000-1000-8000-00805f9b34fb))';
        break;
      case '00002a52-0000-1000-8000-00805f9b34fb':
        title +=
            ' (được sử dụng để chứa thông tin bổ sung liên quan đến một lần đo đường huyết cụ thể. Nó cung cấp thông tin về môi trường và ngữ cảnh xung quanh khi đo đường huyết, như trạng thái mẫu, thông tin về máy đo đường huyết, thời gian từ lần đo trước đó và các chỉ số khác liên quan.)';
        break;
      case '00002a08-0000-1000-8000-00805f9b34fb':
        title +=
            " (được sử dụng để đọc và ghi thông tin về thời gian hiện tại. Nó chứa thông tin về ngày, tháng, năm, giờ, phút, giây và thông tin về múi giờ)";
        break;
      case '00002a23-0000-1000-8000-00805f9b34fb':
        title +=
            " (Characteristic System ID chứa dữ liệu về ID của thiết bị, bao gồm các trường như Manufacturer ID (ID nhà sản xuất), Organizationally Unique Identifier (OUI) và Product ID (ID sản phẩm). Dữ liệu trong Characteristic này có thể được sử dụng để nhận dạng và xác định thiết bị)";
        break;
      case '00002a24-0000-1000-8000-00805f9b34fb':
        title +=
            ' (Characteristic "Model Number String" cung cấp một chuỗi ký tự biểu diễn số hiệu (model number) của thiết bị. Thông qua Characteristic này, bạn có thể nhận được thông tin về mã số hiệu của thiết bị để xác định loại và phiên bản của nó.)';
        break;
      case '00002a25-0000-1000-8000-00805f9b34fb':
        title +=
            ' Characteristic "Serial Number String" cung cấp một chuỗi ký tự biểu diễn số serial (serial number) của thiết bị. Thông qua Characteristic này, bạn có thể nhận được thông tin về số serial của thiết bị để xác định danh tính và định danh duy nhất của nó.';
        break;
      case '00002a26-0000-1000-8000-00805f9b34fb':
        title +=
            ' Characteristic "Serial Number String" cung cấp một chuỗi ký tự biểu diễn số serial (serial number) của thiết bị. Thông qua Characteristic này, bạn có thể nhận được thông tin về số serial của thiết bị để xác định danh tính và định danh duy nhất của nó.';
        break;
      case '00002a29-0000-1000-8000-00805f9b34fb':
        title +=
            ' (Characteristic "Manufacturer Name String" cung cấp một chuỗi ký tự biểu diễn tên nhà sản xuất của thiết bị. Thông qua Characteristic này, bạn có thể nhận được thông tin về nhà sản xuất để xác định nguồn gốc và hỗ trợ kỹ thuật cho thiết bị.';
        break;
      case '00002a2a-0000-1000-8000-00805f9b34fb':
        title +=
            ' (Characteristic "Model Number String" cung cấp một chuỗi ký tự biểu diễn số hiệu của thiết bị. Thông qua Characteristic này, bạn có thể nhận được thông tin về số hiệu để xác định phiên bản, dòng sản phẩm hoặc mô hình cụ thể của thiết bị.)';
        break;
      case '00002a50-0000-1000-8000-00805f9b34fb':
        title +=
            ' (Characteristic "PNP ID" chứa các trường thông tin về nhà sản xuất, loại thiết bị và phiên bản phần cứng của thiết bị. Thông qua Characteristic này, bạn có thể nhận được thông tin xác định về nguồn gốc và tính tương thích của thiết bị.)';
        break;
      case '00000000-0000-1000-1000-000000000001':
        title +=
            'là một UUID tùy chỉnh không chuẩn được định nghĩa trong Bluetooth SIG ( của một Service trong Bluetooth GATT (Generic Attribute Profile). Tuy nhiên, đây không phải là một UUID chuẩn được định nghĩa trong Bluetooth SIG (Bluetooth Special Interest Group). UUID có dạng 00000000-0000-1000-1000-000000000001 thường được sử dụng để đại diện cho một Service tùy chỉnh được tạo ra bởi một ứng dụng hoặc thiết bị cụ thể. Điều này có nghĩa rằng UUID này không có một ý nghĩa cụ thể được định nghĩa trong chuẩn Bluetooth và phụ thuộc hoàn toàn vào cách sử dụng và triển khai của ứng dụng hoặc thiết bị. Nếu bạn gặp UUID này trong ngữ cảnh cụ thể, bạn cần tham khảo tài liệu hoặc thông tin hỗ trợ của ứng dụng hoặc thiết bị đó để hiểu rõ ý nghĩa và chức năng của Service tương ứng.)';
        break;
      case '00000000-0000-1000-1000-000000000002':
        title +=
            ' là một UUID tùy chỉnh không chuẩn được định nghĩa trong Bluetooth SIG (UUID có dạng 00000000-0000-1000-1000-000000000002 thường được sử dụng để đại diện cho một Service tùy chỉnh được tạo ra bởi một ứng dụng hoặc thiết bị cụ thể. Ý nghĩa và chức năng của Service này phụ thuộc hoàn toàn vào cách sử dụng và triển khai của ứng dụng hoặc thiết bị.)';
        break;
      case '00000000-0000-1000-1000-000000000010':
        title +=
            ' là một UUID tùy chỉnh không chuẩn được định nghĩa trong Bluetooth SIG (UUID có dạng 00000000-0000-1000-1000-000000000011 thường được sử dụng để đại diện cho một Characteristic tùy chỉnh trong một Service cụ thể. Ý nghĩa và chức năng của Characteristic này phụ thuộc hoàn toàn vào cách sử dụng và triển khai của ứng dụng hoặc thiết bị tương ứng)';
        break;
      case '00000000-0000-1000-1000-000000000011':
        title +=
            ' là một UUID tùy chỉnh không chuẩn được định nghĩa trong Bluetooth SIG (Tuy nhiên, vì đây là một UUID tùy chỉnh, ý nghĩa và chức năng cụ thể của nó phụ thuộc hoàn toàn vào ngữ cảnh sử dụng. Mỗi ứng dụng hoặc thiết bị có thể định nghĩa các UUID tùy chỉnh riêng để sử dụng trong GATT (Generic Attribute Profile) của Bluetooth)';
        break;
      case '00000000-0000-1000-1000-000000000012':
        title +=
            ' là một UUID tùy chỉnh không chuẩn được định nghĩa trong Bluetooth SIG nhiên, vì đây là một UUID tùy chỉnh, ý nghĩa và chức năng cụ thể của nó phụ thuộc hoàn toàn vào ngữ cảnh sử dụng. Mỗi ứng dụng hoặc thiết bị có thể định nghĩa các UUID tùy chỉnh riêng để sử dụng trong GATT (Generic Attribute Profile) của Bluetooth';
        break;
    }

    return title;
  }

  static parseSFLOAT(List<int> bytes) {
    var mgPerDl = bytes[12];
    print('Blood glucose level: $mgPerDl mg/dL');
    print('Blood glucose level: ${mgPerDl / 18.0182} mmol/L');
  }

  static test(List<int> values) {
    bool timeOffsetPresent = (values[0] & 0x01) > 0;
    bool typeAndLocationPresent = (values[0] & 0x02) > 0;
    String concentrationUnit = (values[0] & 0x04) > 0 ? "mol/L" : "kg/L";
    bool sensorStatusAnnunciationPresent = (values[0] & 0x08) > 0;
    bool contextInfoFollows = (values[0] & 0x10) > 0;

    num seqNum = (values[1] & 255);
    seqNum = (values[2] & 255) << 8;

    int glucose = values[10] & 255;
    glucose |= (values[11] & 255) << 8;

    int year = values[3] & 255;
    year |= (values[4] & 255) << 8;
    var month = values[5];
    var day = values[6];
    var hour = values[7];
    var min = values[8];
    var sec = values[9];
  }
}
