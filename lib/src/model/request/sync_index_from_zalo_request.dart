class SyncIndexFromZaloToPhoneRequest {
  String accountPhone;
  String accountZalo;

  SyncIndexFromZaloToPhoneRequest({
    required this.accountPhone,
    required this.accountZalo,
  });

  factory SyncIndexFromZaloToPhoneRequest.fromJson(Map<String, dynamic> json) {
    return SyncIndexFromZaloToPhoneRequest(
      accountPhone: json['accountPhone'] ?? '',
      accountZalo: json['accountZalo'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountPhone': accountPhone,
      'accountZalo': accountZalo,
    };
  }
}
