class RegisterDocosanUserModel {
  final int id;
  final String prefix;
  final String email;
  final int isActive;
  final String? activationCode;
  final String? birthday;
  final String createdAt;
  final String updatedAt;
  final String phoneNumber;
  final String? avatar;
  final String language;
  final String type;
  final String internal;
  final String? ip;
  final String fromResource;
  final String? googleId;
  final String accessToken;
  final String organize;

  RegisterDocosanUserModel({
    required this.id,
    required this.prefix,
    required this.email,
    required this.isActive,
    this.activationCode,
    this.birthday,
    required this.createdAt,
    required this.updatedAt,
    required this.phoneNumber,
    this.avatar,
    required this.language,
    required this.type,
    required this.internal,
    this.ip,
    required this.fromResource,
    this.googleId,
    required this.accessToken,
    required this.organize,
  });

  factory RegisterDocosanUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterDocosanUserModel(
      id: json['id'] ?? 0,
      prefix: json['prefix'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? 0,
      activationCode: json['activation_code'],
      birthday: json['birthday'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      avatar: json['avatar'],
      language: json['language'] ?? '',
      type: json['type'] ?? '',
      internal: json['internal'] ?? '0',
      ip: json['ip'],
      fromResource: json['from_resource'] ?? '',
      googleId: json['google_id'],
      accessToken: json['access_token'] ?? '',
      organize: json['organize'] ?? '',
    );
  }
}

class RegisterDocosanUserResponse {
  final int code;
  final RegisterDocosanUserModel data;

  RegisterDocosanUserResponse({
    required this.code,
    required this.data,
  });

  factory RegisterDocosanUserResponse.fromJson(Map<String, dynamic> json) {
    return RegisterDocosanUserResponse(
      code: json['code'] ?? 0,
      data: RegisterDocosanUserModel.fromJson(json['data'] ?? {})
    );
  }
}
