import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

enum VNPayHashType {
  SHA256,
  HMACSHA512,
}

class VNPAYFlutter {
  static final VNPAYFlutter _instance = VNPAYFlutter();
  static VNPAYFlutter get instance => _instance;

  String? _lastVnpSecureHash;
  String? get vnpSecureHash => _lastVnpSecureHash;

  String? _lastTxnRef;
  String? get txnRef => _lastTxnRef;

  Map<String, dynamic> _sortParams(Map<String, dynamic> params) {
    final sortedParams = <String, dynamic>{};
    final keys = params.keys.toList()..sort();
    for (String key in keys) {
      sortedParams[key] = params[key];
    }
    return sortedParams;
  }

  String generatePaymentUrl({
    String url = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
    required String version,
    String command = 'pay',
    required String tmnCode,
    String locale = 'vn',
    String currencyCode = 'VND',
    required String txnRef,
    String orderInfo = 'Pay Order',
    required double amount,
    String? returnUrl,
    required String ipAdress,
    String? createAt,
    String? expireAt,
    String orderType = "other",
    required String vnpayHashKey,
    VNPayHashType vnPayHashType = VNPayHashType.HMACSHA512,
  }) {
    final params = <String, dynamic>{
      'vnp_Version': version,
      'vnp_Command': command,
      'vnp_TmnCode': tmnCode,
      'vnp_Locale': locale,
      'vnp_CurrCode': currencyCode,
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': orderType,
      'vnp_Amount': (amount * 100).toStringAsFixed(0),
      'vnp_ReturnUrl': returnUrl,
      'vnp_IpAddr': ipAdress,
      'vnp_CreateDate': createAt ??
          DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString(),
      'vnp_ExpireDate': expireAt ??
          DateFormat('yyyyMMddHHmmss')
              .format(DateTime.now().add(Duration(minutes: 5)))
              .toString(),
    };
    var sortedParam = _sortParams(params);
    final hashDataBuffer = StringBuffer();
    sortedParam.forEach((key, value) {
      hashDataBuffer.write(key);
      hashDataBuffer.write('=');
      hashDataBuffer.write(value);
      hashDataBuffer.write('&');
    });
    String hashData =
        hashDataBuffer.toString().substring(0, hashDataBuffer.length - 1);
    String query = Uri(queryParameters: sortedParam).query;

    String vnpSecureHash = "";

    if (vnPayHashType == VNPayHashType.SHA256) {
      List<int> bytes = utf8.encode(vnpayHashKey + hashData.toString());
      vnpSecureHash = sha256.convert(bytes).toString();
    } else {
      vnpSecureHash = Hmac(sha512, utf8.encode(vnpayHashKey))
          .convert(utf8.encode(query))
          .toString();
    }

    _lastVnpSecureHash = vnpSecureHash;
    _lastTxnRef = txnRef;

    String paymentUrl = "$url?$query&vnp_SecureHash=$vnpSecureHash";
    return paymentUrl;
  }
}

class VnpayResponseCode {
  static const Map<String, String> codes = {
    "00": "Giao dịch thành công",
    "07":
        "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).",
    "09":
        "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng.",
    "10":
        "Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần",
    "11":
        "Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch.",
    "12":
        "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa.",
    "13":
        "Giao dịch không thành công do Quý khách nhập sai mật khẩu xác thực giao dịch (OTP). Xin quý khách vui lòng thực hiện lại giao dịch.",
    "24": "Giao dịch không thành công do: Khách hàng hủy giao dịch",
    "51":
        "Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.",
    "65":
        "Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày.",
    "75": "Ngân hàng thanh toán đang bảo trì.",
    "79":
        "Giao dịch không thành công do: KH nhập sai mật khẩu thanh toán quá số lần quy định. Xin quý khách vui lòng thực hiện lại giao dịch",
    "99": "Các lỗi khác",
  };
  static const String defaultMessage = "Các lỗi khác";
  static String getResponseCodeMessage(String code) {
    return codes[code] ?? defaultMessage;
  }
}

class VnpayTransactionStatus {
  static const Map<String, String> codes = {
    "00": "Giao dịch thành công",
    "01": "Giao dịch chưa hoàn tất",
    "02": "Giao dịch bị lỗi",
    "04":
        "Giao dịch đảo (Khách hàng đã bị trừ tiền tại Ngân hàng nhưng GD chưa thành công ở VNPAY)",
    "05": "VNPAY đang xử lý giao dịch này (GD hoàn tiền)",
    "06": "VNPAY đã gửi yêu cầu hoàn tiền sang Ngân hàng (GD hoàn tiền)",
    "07": "Giao dịch bị nghi ngờ gian lận",
    "09": "GD Hoàn trả bị từ chối",
  };
  static const String defaultMessage = "Giao dịch bị lỗi";

  static String getStatusMessage(String code) {
    return codes[code] ?? defaultMessage;
  }
}
