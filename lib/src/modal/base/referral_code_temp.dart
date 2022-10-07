class ReferralCodeTemp {
  final String phoneNumber;
  final String referralCode;

  const ReferralCodeTemp({
    required this.phoneNumber,
    required this.referralCode,
  });

  @override
  factory ReferralCodeTemp.fromJson(Map<String, dynamic> json) {
    return ReferralCodeTemp(
      phoneNumber: json['phoneNumber'],
      referralCode: json['referralCode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["phoneNumber"] = phoneNumber;
    data["referralCode"] = referralCode;
    return data;
  }
}
