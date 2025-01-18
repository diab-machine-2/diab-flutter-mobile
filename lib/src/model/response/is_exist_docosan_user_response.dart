class IsExistDocosanUserResponse {
  IsExistDocosanUserResponse({
    required this.isExists,
  });

  bool isExists;

  factory IsExistDocosanUserResponse.fromJson(Map<String, dynamic> json) =>
      IsExistDocosanUserResponse(
        isExists: json["is_exists"],
      );
}
