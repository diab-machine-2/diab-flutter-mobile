class RegisterDocosanUserRequest {
  final String email;
  final String type;
  final String displayName;
  final String gender;
  String? language;
  final String isGetCaresOrderInfo;
  final String phoneNumber;

  RegisterDocosanUserRequest({
    required this.email,
    required this.type,
    required this.displayName,
    required this.gender,
    this.language,
    required this.isGetCaresOrderInfo,
    required this.phoneNumber,
  });

  factory RegisterDocosanUserRequest.fromJson(Map<String, dynamic> json) {
    return RegisterDocosanUserRequest(
      email: json['email'] ?? '',
      type: json['type'] ?? '',
      displayName: json['display_name'] ?? '',
      gender: json['gender'] ?? '',
      language: json['language'] ?? '',
      isGetCaresOrderInfo: json['is_get_cares_order_info'] ?? '0',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'type': type,
      'display_name': displayName,
      'gender': gender,
      'language': language,
      'is_get_cares_order_info': isGetCaresOrderInfo,
      'phone_number': phoneNumber,
    };
  }
}
