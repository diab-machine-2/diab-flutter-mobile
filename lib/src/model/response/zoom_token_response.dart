class ZoomTokenResponse {
  ZoomTokenResponse({
    required this.token,
    required this.sessionName,
    required this.displayName,
    required this.sessionIdleTimeoutMins,
    required this.sessionPassword,
  });

  String token;
  String sessionName;
  String? displayName;
  String sessionIdleTimeoutMins;
  String sessionPassword;

  factory ZoomTokenResponse.fromJson(Map<String, dynamic> json) => ZoomTokenResponse(
        token: json["Token"].toString(),
        sessionName: json["SessionName"].toString(),
        displayName: json["DisplayName"]?.toString(),
        sessionIdleTimeoutMins: json["SessionIdleTimeoutMins"].toString(),
        sessionPassword: json["SessionPassword"].toString(),
      );
}
