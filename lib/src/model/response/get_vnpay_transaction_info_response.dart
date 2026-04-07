class GetVnpayTransactionInfoResponse {
  final String? vnpCardType;
  final String? vnpPayDate;
  final String? vnpResponseCode;
  final String? vnpTransactionStatus;
  final String? vnpTxnRef;

  GetVnpayTransactionInfoResponse({
    this.vnpCardType,
    this.vnpPayDate,
    this.vnpResponseCode,
    this.vnpTransactionStatus,
    this.vnpTxnRef,
  });

  factory GetVnpayTransactionInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetVnpayTransactionInfoResponse(
      vnpCardType: json['vnpCardType'] as String?,
      vnpPayDate: json['vnpPayDate'] as String?,
      vnpResponseCode: json['vnpResponseCode'] as String?,
      vnpTransactionStatus: json['vnpTransactionStatus'] as String?,
      vnpTxnRef: json['vnpTxnRef'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vnpCardType': vnpCardType,
      'vnpPayDate': vnpPayDate,
      'vnpResponseCode': vnpResponseCode,
      'vnpTransactionStatus': vnpTransactionStatus,
      'vnpTxnRef': vnpTxnRef,
    };
  }

  Map<String, dynamic> toJsonFormatted() {
    return {
      'vnp_CardType': vnpCardType,
      'vnp_PayDate': vnpPayDate,
      'vnp_ResponseCode': vnpResponseCode,
      'vnp_TransactionStatus': vnpTransactionStatus,
      'vnp_TxnRef': vnpTxnRef,
    };
  }

  @override
  String toString() {
    return 'GetVnpayTransactionInfoResponse('
        'vnpCardType: $vnpCardType, '
        'vnpPayDate: $vnpPayDate, '
        'vnpResponseCode: $vnpResponseCode, '
        'vnpTransactionStatus: $vnpTransactionStatus, '
        'vnpTxnRef: $vnpTxnRef)';
  }
}
