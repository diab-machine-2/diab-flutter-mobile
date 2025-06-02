class VnpayPaymentRequest {
  final String phoneNumber;
  final String accountId;
  final String appointmentId;
  final String vnpTmnCode;
  final String vnpAmount;
  final String? vnpBankCode;
  final String? vnpBankTranNo;
  final String? vnpCardType;
  final String vnpPayDate;
  final String vnpOrderInfo;
  final String vnpTransactionNo;
  final String vnpResponseCode;
  final String vnpTransactionStatus;
  final String vnpTxnRef;
  final String vnpSecureHash;

  VnpayPaymentRequest({
    required this.phoneNumber,
    required this.accountId,
    required this.appointmentId,
    required this.vnpTmnCode,
    required this.vnpAmount,
    this.vnpBankCode,
    this.vnpBankTranNo,
    this.vnpCardType,
    required this.vnpPayDate,
    required this.vnpOrderInfo,
    required this.vnpTransactionNo,
    required this.vnpResponseCode,
    required this.vnpTransactionStatus,
    required this.vnpTxnRef,
    required this.vnpSecureHash,
  });

  Map<String, String> toFormData() {
    final Map<String, String> formData = {
      'phoneNumber': phoneNumber,
      'accountId': accountId,
      'appointmentId': appointmentId,
      'vnpTmnCode': vnpTmnCode,
      'vnpAmount': vnpAmount,
      'vnpPayDate': vnpPayDate,
      'vnpOrderInfo': vnpOrderInfo,
      'vnpTransactionNo': vnpTransactionNo,
      'vnpResponseCode': vnpResponseCode,
      'vnpTransactionStatus': vnpTransactionStatus,
      'vnpTxnRef': vnpTxnRef,
      'vnpSecureHash': vnpSecureHash,
    };

    // Add optional fields if they are not null
    if (vnpBankCode != null) {
      formData['vnpBankCode'] = vnpBankCode!;
    }
    if (vnpBankTranNo != null) {
      formData['vnpBankTranNo'] = vnpBankTranNo!;
    }
    if (vnpCardType != null) {
      formData['vnpCardType'] = vnpCardType!;
    }

    return formData;
  }

  factory VnpayPaymentRequest.fromJson(Map<String, dynamic> json) {
    return VnpayPaymentRequest(
      phoneNumber: json['phoneNumber'] ?? '',
      accountId: json['accountId'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      vnpTmnCode: json['vnpTmnCode'] ?? '',
      vnpAmount: json['vnpAmount'] ?? '',
      vnpBankCode: json['vnpBankCode'],
      vnpBankTranNo: json['vnpBankTranNo'],
      vnpCardType: json['vnpCardType'],
      vnpPayDate: json['vnpPayDate'] ?? '',
      vnpOrderInfo: json['vnpOrderInfo'] ?? '',
      vnpTransactionNo: json['vnpTransactionNo'] ?? '',
      vnpResponseCode: json['vnpResponseCode'] ?? '',
      vnpTransactionStatus: json['vnpTransactionStatus'] ?? '',
      vnpTxnRef: json['vnpTxnRef'] ?? '',
      vnpSecureHash: json['vnpSecureHash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'phoneNumber': phoneNumber,
      'accountId': accountId,
      'appointmentId': appointmentId,
      'vnpTmnCode': vnpTmnCode,
      'vnpAmount': vnpAmount,
      'vnpPayDate': vnpPayDate,
      'vnpOrderInfo': vnpOrderInfo,
      'vnpTransactionNo': vnpTransactionNo,
      'vnpResponseCode': vnpResponseCode,
      'vnpTransactionStatus': vnpTransactionStatus,
      'vnpTxnRef': vnpTxnRef,
      'vnpSecureHash': vnpSecureHash,
    };

    if (vnpBankCode != null) {
      json['vnpBankCode'] = vnpBankCode;
    }
    if (vnpBankTranNo != null) {
      json['vnpBankTranNo'] = vnpBankTranNo;
    }
    if (vnpCardType != null) {
      json['vnpCardType'] = vnpCardType;
    }

    return json;
  }

  @override
  String toString() {
    return 'VnpayPaymentRequest('
        'phoneNumber: $phoneNumber, '
        'accountId: $accountId, '
        'appointmentId: $appointmentId, '
        'vnpTmnCode: $vnpTmnCode, '
        'vnpAmount: $vnpAmount, '
        'vnpBankCode: $vnpBankCode, '
        'vnpBankTranNo: $vnpBankTranNo, '
        'vnpCardType: $vnpCardType, '
        'vnpPayDate: $vnpPayDate, '
        'vnpOrderInfo: $vnpOrderInfo, '
        'vnpTransactionNo: $vnpTransactionNo, '
        'vnpResponseCode: $vnpResponseCode, '
        'vnpTransactionStatus: $vnpTransactionStatus, '
        'vnpTxnRef: $vnpTxnRef, '
        'vnpSecureHash: $vnpSecureHash)';
  }
}
