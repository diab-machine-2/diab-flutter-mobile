class AppVersionResponse {
  AppVersionResponse({
    this.id,
    this.code,
    this.platform,
    this.version,
    this.enviroment,
  });

  String? id;
  String? code;
  String? platform;
  String? version;
  String? enviroment;

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) => AppVersionResponse(
        id: json["id"],
        code: json["code"],
        platform: json["platform"],
        version: json["version"],
        enviroment: json["enviroment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "platform": platform,
        "version": version,
        "enviroment": enviroment,
      };
}