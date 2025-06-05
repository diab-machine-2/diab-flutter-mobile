class VnpayPaymentRequest {
  final String phoneNumber;
  final String accountId;
  final String vnpTmnCode;
  final String vnpAmount;
  final String vnpOrderInfo;
  final String vnpTxnRef;
  final String vnpSecureHash;

  VnpayPaymentRequest({
    required this.phoneNumber,
    required this.accountId,
    required this.vnpTmnCode,
    required this.vnpAmount,
    required this.vnpOrderInfo,
    required this.vnpTxnRef,
    required this.vnpSecureHash,
  });

  Map<String, String> toFormData() {
    final Map<String, String> formData = {
      'phoneNumber': phoneNumber,
      'accountId': accountId,
      'vnpTmnCode': vnpTmnCode,
      'vnpAmount': vnpAmount,
      'vnpOrderInfo': vnpOrderInfo,
      'vnpTxnRef': vnpTxnRef,
      'vnpSecureHash': vnpSecureHash,
    };

    return formData;
  }

  factory VnpayPaymentRequest.fromJson(Map<String, dynamic> json) {
    return VnpayPaymentRequest(
      phoneNumber: json['phoneNumber'] ?? '',
      accountId: json['accountId'] ?? '',
      vnpTmnCode: json['vnpTmnCode'] ?? '',
      vnpAmount: json['vnpAmount'] ?? '',
      
      vnpOrderInfo: json['vnpOrderInfo'] ?? '',
      vnpTxnRef: json['vnpTxnRef'] ?? '',
      vnpSecureHash: json['vnpSecureHash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'phoneNumber': phoneNumber,
      'accountId': accountId,
      'vnpTmnCode': vnpTmnCode,
      'vnpAmount': vnpAmount,
      'vnpOrderInfo': vnpOrderInfo,
      'vnpTxnRef': vnpTxnRef,
      'vnpSecureHash': vnpSecureHash,
    };


    return json;
  }

  @override
  String toString() {
    return 'VnpayPaymentRequest('
        'phoneNumber: $phoneNumber, '
        'accountId: $accountId, '
        'vnpTmnCode: $vnpTmnCode, '
        'vnpAmount: $vnpAmount, '
        'vnpOrderInfo: $vnpOrderInfo, '
        'vnpTxnRef: $vnpTxnRef, '
        'vnpSecureHash: $vnpSecureHash)';
  }
}
